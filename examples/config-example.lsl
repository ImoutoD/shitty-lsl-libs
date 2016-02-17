//Notecard-based configuration example

#include <keyvalueconfigsystem.lsli>

////////////
//Settings//
////////////

//the name of our config notecard
string CONFIG_NAME = "config";

//settings that are required to be in our setting notecard
list REQUIRED_SETTINGS = ["anicebool", "anicestring", "anicevector"];

////////////////
//Setting Vars//
////////////////

//a set of test settings we use to demonstrate the system
integer gANiceBool;
string gANiceString;
vector gANiceVector;
integer gOptionalInteger;




//***********************************//
//User defined functions and handlers//
//***********************************//

//the config has been unloaded, reset all of our variables to their default values
resetSettings()
{
    gANiceBool = INVALID_BOOL;
    gANiceString = "";
    gANiceVector = ZERO_VECTOR;
    gOptionalInteger = 0;
}

//assign a value to a variable that was set in the config notecard
assignConfigVar(string akey, string value)
{
    if(akey == "anicebool")
        //use str2bool to convert "on"/"off", "true"/"false", etc to their proper boolean value
        gANiceBool = str2Bool(value);
    else if(akey == "anicestring")
        gANiceString = value;
    else if(akey == "anicevector")
        gANiceVector = (vector)value;
    else if(akey == "anoptionalinteger")
        gOptionalInteger = (integer)value;
}

//whether all of the config vars are set (you should also check if the values are valid here, if necessary)
//in this example we'll allow empty strings and vectors, but invalid booleans are rejected
integer isConfigComplete()
{
    return areRequiredSettingsSet() &&
           gANiceBool != INVALID_BOOL;
}




configNotFound()
{
    llOwnerSay("Please place the '" + CONFIG_NAME + "' notecard into this object's inventory.");
}

configUnloaded()
{
}

configLoading()
{
    llOwnerSay("Loading the configuration");
}

configLoadFailed()
{
    llOwnerSay("Your configuration was not of the correct format or was not filled out. Please try rewriting it");
}

configLoadSuccess()
{
    //normally we'd do... something once the config loaded properly, but for this example we'll just tell the owner what we loaded
    string stringified_config = (string)gANiceBool + "|" + gANiceString + "|" + (string)gANiceVector;

    //if our optional setting was set, add it to the string
    if(isSettingSet("anoptionalinteger"))
        stringified_config += "|" + (string)gOptionalInteger;

    llOwnerSay("Config Loaded: " + stringified_config);
}



default
{
    state_entry()
    {
        // Start up.
        loadConfig();
    }
    
    //we restart on rez for this example
    on_rez(integer start_params)
    {
        if(!gSettingsLoaded)
            loadConfig();
    }
    
    changed(integer change)
    {
        //if the inventory loaded and it was the config notecard, reload the config
        if(change & CHANGED_INVENTORY)
            if(isConfigChanged())
                loadConfig();
    }
    
    dataserver(key queryid, string data)
    {
        if(queryid == gNotecardHandle)
        {
            handleConfigData(data);
        }
    }
}
