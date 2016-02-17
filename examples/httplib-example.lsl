//An example of the LSL HTTP API code, with both the client and server in
//the same script (you probably never want to do that)

//the API URL is whatever URL is assigned to the LSL HTTP server
#define API_URL gURL + "/"

#define API_VERSION 1

//string that precedes every request
#define HTTP_API_HEADER (string)API_VERSION
//minimum length of a valid request (in elements)
#define MIN_REQUEST_LEN 2

//since this script isn't all that useful, the maintainer is probably the owner
#define MAINTAINER_ID llGetOwner()
//string that identifies the client object making the request
#define CLIENT_IDENTIFIER (string)llGetKey()

//index of the API version in a request
#define REQUEST_VERSION 0
//index of the start of the params in a request
#define REQUEST_PARAMS 1

//first param for a test method request
#define TEST_GREET_WHO 0

//use encryption and validation when communicating with the server
#define CRYPTED_API
list XTEA_KEY = [24362, -634743, 574235, -501];
string HASH_SECRET = "Set this to something random so people can't pack their own valid messages, even if they know the key";

#include <lists.lsli>
#include <httplib.lsli>

//URL for the API server
string gURL;
key gURLRequest = NULL_KEY;

/* CLIENT IMPL */

//error codes and their corresponding messages
//Format: string error_code, integer intended_recipient, integer fatal, string error_message
list ERRORS = [
    "error_error", 6, 1, "there was an error getting your error message, the error code was: ",
    "generic_error", 1, 1, "An error occurred during the operation and has been noted, please try again later",
    
    "invalid_version", 6, 1, "The version you are using is too old, please upgrade.",
    "invalid_request", 6, 1, "The client made a request the server didn't understand",
    "invalid_params", 6, 1, "The parameters of your request weren't valid",
    "invalid_response", 6, 1, "The response we received from the server wasn't properly formed."
];

//handle an HTTP response code indicating failure
implHandleHTTPRequestError(integer request_index, key user_key)
{
    if(user_key != NULL_KEY)
    {
        //let the user know what happened
        if(user_key != MAINTAINER_ID && user_key != llGetOwner())
            llInstantMessage(user_key, "Unfortunately, your transaction could not be completed due to a technical error.");
    }
}

//handle a response from the server indicating failure
implHandleResponseError(integer request_index, key customer_key, string method, string error_code, integer fatal)
{
    if(fatal)
    {
        llOwnerSay("That was a fatal error!");
    }
    else
    {
        llOwnerSay("We received an error, but we can probably keep going");
    }
}

//handle the response from the server
implHandleHTTPResponse(integer request_index, string method, list params)
{
    if(method == "test")
    {
        llRegionSayTo(
            L2K(gPendingRequests, request_index + PENDING_REQUEST_REQUESTER),
            0,
            L2S(params, TEST_GREET_WHO)
        );
    }
}

/* END CLIENT IMPL */

default
{
    state_entry()
    {
        llRequestSecureURL();
    }
    http_request(key id, string method, string body)
    {
        if (method == URL_REQUEST_GRANTED)
        {
            gURL = body;
            
            //ask the server to send back a greeting for the owner
            serverRequest(llGetOwner(), "test", "", ["world"]);
            //a request that won't complete successfully
            serverRequest(llGetOwner(), "something_else", "", ["foo", "bar"]);
        }
        else if (method == "POST")
        {
            list request = unpackRequest(body);
            
            //request contains too few elems, definitely bogus.
            if(LIST_LEN(request) < MIN_REQUEST_LEN)
            {
                serverResponse(id, "invalid_request", []);
                return;
            }
            
            integer version = L2I(request, REQUEST_VERSION);
            list params = L2L(request, REQUEST_PARAMS, -1);
            
            string method = llGetSubString(llGetHTTPHeader(id, "x-path-info"), 1, -1);
            
            //we don't support the API version of the request
            if(version != API_VERSION)
            {
                serverResponse(id, "invalid_version", []);
                return;
            }
            
            if(method == "test")
            {
                serverResponse(id, "success", ["Hello, " + L2S(params, TEST_GREET_WHO) + "!"]);
            }
            else
            {
                llHTTPResponse(id, 404, "We don't know anything about that method!");
            }
        }
        else
        {
            llHTTPResponse(id, 405, "POST request required!");
        }
    }
    http_response(key id, integer status, list meta, string body)
    {
        if(!tryHandleAPIResponse(id, status, body))
        {
            //handle non api-related http responses here...
        }
    }
}
