// =========================================================================================================
//  SAR_AI - DayZ AI library
//  Version: 1.1.0 
//  Author: Sarge (sarge@krumeich.ch) 
//
//		Wiki: to come
//		Forum: http://opendayz.net/index.php?threads/sarge-ai-framework-public-release.8391/
//		
// ---------------------------------------------------------------------------------------------------------
//  Required:
//  UPSMon  (specific SARGE version)
//  SHK_pos 
//  
// ---------------------------------------------------------------------------------------------------------
//   SAR_vehicle_fix.sqf
//   last modified: 1.4.2013
// ---------------------------------------------------------------------------------------------------------

    private ["_dummy","_i","_gridwidth","_markername","_triggername","_trig_act_stmnt","_trig_deact_stmnt","_trig_cond","_emptyarr","_pos"];

    if (!isServer) exitWith {}; // only run this on the server
    
    
    // wait until the server has spawned all the vehicles ... might take a while
    // how to figure out IF theae have all been spawned ?
    sleep 15;

    if(SAR_DEBUG) then {diag_log "SAR_DEBUG: Initialized fix for faction vehicle issue.";};
    
    
    SAR_grp_friendly = createGroup SAR_AI_friendly_side;
    SAR_grp_friendly setVariable ["SAR_protect",true,true];
     
    SAR_grp_unfriendly = createGroup SAR_AI_unfriendly_side;
    SAR_grp_unfriendly setVariable ["SAR_protect",true,true];
    
    setGroupIconsVisible [false,false];
     
     // SARGE TODO: find a safe spot for all maps to store the 2 dummies
     // this will take some time, but is only run once at the server start
    _dummy = SAR_grp_unfriendly createunit ["Rocket_DZ", [2500, 13100, 0], [],0, "FORM"];

    [nil, _dummy, "per", rhideObject, true] call RE;
    [nil, _dummy, "per", rallowDamage, false] call RE;
    _dummy disableAI "FSM";
    _dummy disableAI "ANIM";
    _dummy disableAI "MOVE";
    _dummy disableAI "TARGET";
    _dummy disableAI "AUTOTARGET";
    _dummy setVehicleInit "this setIdentity 'id_SAR';this hideObject true;this allowDamage false;";
    [_dummy] joinSilent SAR_grp_unfriendly;
    SAR_grp_unfriendly selectLeader _dummy;

    // set variable to group so it doesnt get cleaned up
    SAR_grp_unfriendly setVariable ["SAR_protect",true,true];

    
    _dummy = SAR_grp_friendly createunit ["Rocket_DZ", [2500, 13100, 0], [],0, "FORM"];

    [nil, _dummy, "per", rhideObject, true] call RE;
    [nil, _dummy, "per", rallowDamage, false] call RE;
    _dummy disableAI "FSM";
    _dummy disableAI "ANIM";
    _dummy disableAI "MOVE";
    _dummy disableAI "TARGET";
    _dummy disableAI "AUTOTARGET";
    _dummy setVehicleInit "this setIdentity 'id_SAR';this hideObject true;this allowDamage false;";
    [_dummy] joinSilent SAR_grp_friendly;
    SAR_grp_friendly selectLeader _dummy;

    // set variable to group so it doesnt get cleaned up
    SAR_grp_friendly setVariable ["SAR_protect",true,true];
    
    if(SAR_DEBUG) then {
        diag_log format["Created a friendly placeholder group: %1",SAR_grp_friendly];
        diag_log format["Created an unfriendly placeholder group: %1",SAR_grp_unfriendly];
    };
        

    //[dayz_serverObjectMonitor] call SAR_debug_array;
    
    _i=0;
    _gridwidth = 10;
    _emptyarr = [];
     
    {
    
        if (_x isKindOf "AllVehicles") then { // just do this for vehicles, not other objects like tents
        
            _triggername = format["SAR_veh_trig_%1",_i];

            _this = createTrigger ["EmptyDetector", [0,0]];
            _this setTriggerArea [_gridwidth,_gridwidth, 0, false];
            _this setTriggerActivation ["ANY", "PRESENT", true];
            _this setVariable ["unitlist",[],true];

            Call Compile Format ["SAR_veh_trig_%1 = _this",_i]; 
            
            _trig_act_stmnt = format["[thislist,thisTrigger,'%1'] spawn SAR_AI_veh_trig_on_static;",_triggername];
            _trig_deact_stmnt = format["[thislist,thisTrigger,'%1'] spawn SAR_AI_veh_trig_off;",_triggername];

            _trig_cond = "{(isPlayer _x) && (vehicle _x == _x) } count thisList != count (thisTrigger getVariable['unitlist',[]]);";

            Call Compile Format ["SAR_veh_trig_%1",_i] setTriggerStatements [_trig_cond,_trig_act_stmnt , _trig_deact_stmnt];

            Call Compile Format ["SAR_veh_name_%1 = _x",_i]; 
            Call Compile Format ["SAR_veh_trig_%1",_i] attachTo [Call Compile Format ["SAR_veh_name_%1",_i],[0,0,0]];


            if(SAR_EXTREME_DEBUG) then { // show areamarkers around vehicles

                _markername = format["SAR_mar_trig_%1",_i];

                _pos = getPos _x;
                _this = createMarker[_markername,_pos];

                _this setMarkerAlpha 1;
                if (_x isKindOf "Air") then {
                    _this setMarkerShape "ELLIPSE";
                } else {
                    _this setMarkerShape "RECTANGLE";
                };
                _this setMarkerType "Flag";
                _this setMarkerBrush "BORDER";
                _this setMarkerSize [_gridwidth, _gridwidth];
                        
                Call Compile Format ["SAR_testarea_%1 = _this",_i]; 

            };
            
            _i = _i + 1;
        
        };
    
    } foreach dayz_serverObjectMonitor;
    
    
    //diag_log format["--------------------------------------------",nil];
    //diag_log format["SAR_grp_friendly = %1",SAR_grp_friendly];
    //diag_log format["SAR_grp_unfriendly = %1",SAR_grp_unfriendly];
    //diag_log format["--------------------------------------------",nil];    
    
    /*
    _testgrp = createGroup west;

    _this = _testgrp createunit ["Rocket_DZ", [2500, 13100, 0], [], 0.5, "FORM"];

    _this setVehicleInit "this setIdentity 'id_SAR';";

    // change to getnearest
    _this moveInDriver (_cars select 0); 
  

    [_this] joinsilent _testgrp;
    _testgrp selectLeader _this;

    _this disableAI "MOVE";

    _this = _testgrp createunit ["Rocket_DZ", [2500, 13100, 0], [], 0.5, "FORM"];
    _this setVehicleInit "this setIdentity 'id_SAR';";
    _this moveInCargo (_cars select 0); 
    [_this] joinsilent _testgrp;
    _this disableAI "MOVE";

    _this = _testgrp createunit ["Rocket_DZ", [2500, 13100, 0], [], 0.5, "FORM"];
    _this setVehicleInit "this setIdentity 'id_SAR';";
    _this moveInCargo (_cars select 0); 
    [_this] joinsilent _testgrp;
    _this disableAI "MOVE";

*/