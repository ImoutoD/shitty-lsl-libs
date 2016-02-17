//max number of active sessions
#define SESSION_MAX 10
//session activity timeout in seconds
#define SESSION_TIMEOUT 60

#include <menusystem_defaults.lsli>
#include <menusystem.lsli>

//how often to collect garbage
#define GARBAGE_COLLECTION_INTERVAL 60.

string MENU_LABEL_MAIN = "Main Menu";
list MENU_BUTTONS_MAIN = ["Test 1", "Test 2"];

#define MENU_TEST1 1
string MENU_LABEL_TEST1 = "Test Menu 1";
list MENU_BUTTONS_TEST1 = ["Foo", "Bar"];

#define MENU_TEST2 2
string MENU_LABEL_TEST2 = "Test Menu 2 for ";

//Standard menu generation. If you need to do anything funky, call displayDialog
//or displayTextbox yourself.
showMenu(integer session_idx, integer menu)
{
    if(menu == MENU_TEST2)
        displayDialog(
            session_idx, 
            MENU_TEST2, 
            genMenuTest2(), 
            MENU_LABEL_TEST2 + llKey2Name(L2K(gDialogSessions, session_idx + SESSION_ID)),
            -1
        );
    else if(menu == MENU_TEST1)
        displayDialog(session_idx, MENU_TEST1, MENU_BUTTONS_TEST1, MENU_LABEL_TEST1, -1);
    else if(menu == MENU_MAIN)
        displayDialog(session_idx, MENU_MAIN, MENU_BUTTONS_MAIN, MENU_LABEL_MAIN, -1);
}


//figure out which menu handler this response needs to be sent to
integer dispatchDialogResponse(integer session_idx, integer menu_id, string response)
{
    //dispatch the response to the last menu's response handler
    if(menu_id == MENU_MAIN)
        return handleMenuMainResponse(session_idx, response);
    else if(menu_id == MENU_TEST1)
        return handleMenuTest1Response(session_idx, response);
    else if(menu_id == MENU_TEST2)
        return handleMenuTest2Response(session_idx, response);
    else
    {
        llInstantMessage(llGetOwner(), "You need to create a handler for this menu!\n"+
                                       "MenuID: " + (string)menu_id);
        return MENU_NONE;
    }
}

string curDay()
{
    return llList2String(["Thu", "Fri", "Sat", "Sun", "Mon", "Tue", "Wed"], 
        (((llGetUnixTime()/3600) - 4)/24)%7
    );
}

list genMenuTest2()
{
    string day = curDay() + " ";
    list buttons;
    
    integer i = 0;
    
    do
    {
        buttons = buttons + [day + (string)i];
    }while(++i < 20);
    
    return buttons;
}


//////////////////////////
//Menu Response Handlers//
//////////////////////////

//handle a response to the main menu
integer handleMenuMainResponse(integer session_idx, string response)
{
    //handle dialog button presses now
    if(response == "Test 1")
        return MENU_TEST1;
    else if(response == "Test 2")
        return MENU_TEST2;
        
    return MENU_NONE;
}

integer handleMenuTest1Response(integer session_idx, string response)
{
    if(response == NAV_BACK)
        return MENU_MAIN;
    else if(response == "Foo")
        llWhisper(0, "Foo button pressed!");
    else if(response == "Bar")
        llWhisper(0, "You pressed the Bar button!");
        
    return MENU_NONE;
}

integer handleMenuTest2Response(integer session_idx, string response)
{
    if(response == NAV_BACK)
        return MENU_MAIN;
    else
        llWhisper(0, "Test 2 button: " + response);
        
    return MENU_NONE;
}

default
{
    state_entry()
    {
        //tell the script how often to collect garbage
        llSetTimerEvent(GARBAGE_COLLECTION_INTERVAL);
    }
    
    on_rez(integer start_params)
    {
        endAllDialogSessions();
    }
    
    timer()
    {
        //take out the garbage!
        garbageCollection();
    }
    
    touch_start(integer num_detected)
    {
        //handle all these damn people clicking while we were busy
        integer i = 0;
        do
        {
            integer session_idx = sessionStart(llDetectedKey(i));
            
            if(session_idx != -1)
                showMenu(session_idx, MENU_MAIN);
        }
        while(++i < num_detected);
    }
    
    //handle dialog responses (and other listens)
    listen(integer channel, string name, key id, string message)
    {
        if(handleDialogResponse(channel, name, id, message))
            return;
    }
}
