___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Request Repeater",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Edit incoming request parameters and send / forward to any endpoint",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "newServer",
    "displayName": "New Server (No Path)",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "defaultValue": "https://www.google-analytics.com"
  },
  {
    "type": "SELECT",
    "name": "requestMethod",
    "displayName": "Request Method",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "No Change",
        "displayValue": "No Change"
      },
      {
        "value": "POST",
        "displayValue": "POST"
      },
      {
        "value": "GET",
        "displayValue": "GET"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "No Change",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "CHECKBOX",
    "name": "useOriginalPath",
    "checkboxText": "Change Request Path",
    "simpleValueType": true,
    "defaultValue": false,
    "help": "Original request path will be used. If forwarding needs a different endpoint URL on the new server, check option and specify new path"
  },
  {
    "type": "TEXT",
    "name": "newRequestPath",
    "displayName": "New Request Path",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "defaultValue": "/",
    "enablingConditions": [
      {
        "paramName": "useOriginalPath",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "enter path beginning with \"/\" and without \"?\""
  },
  {
    "type": "GROUP",
    "name": "grpChangeParams",
    "displayName": "Edit Request Parameters",
    "groupStyle": "ZIPPY_OPEN",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "deleteParamTable",
        "displayName": "Delete Parameters",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Parameter Name",
            "name": "paramName",
            "type": "TEXT"
          }
        ]
      },
      {
        "type": "SIMPLE_TABLE",
        "name": "changeParamTable",
        "displayName": "Change \u0026 Add Parameters",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Parameter Name",
            "name": "paramName",
            "type": "TEXT"
          },
          {
            "defaultValue": "",
            "displayName": "New Value",
            "name": "paramValue",
            "type": "TEXT"
          },
          {
            "defaultValue": "no",
            "displayName": "Add If Not Found",
            "name": "addParam",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "yes",
                "displayValue": "yes"
              },
              {
                "value": "no",
                "displayValue": "no"
              }
            ]
          }
        ]
      },
      {
        "type": "CHECKBOX",
        "name": "redactValues",
        "checkboxText": "Redact Values",
        "simpleValueType": true,
        "alwaysInSummary": false,
        "help": "Optional redaction of remaining parameters with regex patterns."
      },
      {
        "type": "GROUP",
        "name": "grpRegex",
        "displayName": "Regex List",
        "groupStyle": "NO_ZIPPY",
        "subParams": [
          {
            "type": "LABEL",
            "name": "infoRegex",
            "displayName": "Add one or multiple rows with regex expressions to apply to all remaining parameter values. Matching strings will be replaced."
          },
          {
            "type": "SIMPLE_TABLE",
            "name": "redactPatterns",
            "displayName": "Regex Pattern",
            "simpleTableColumns": [
              {
                "defaultValue": "",
                "displayName": "",
                "name": "rgx",
                "type": "TEXT"
              }
            ],
            "help": "Example for email addresses: [a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+"
          },
          {
            "type": "TEXT",
            "name": "redactReplacement",
            "displayName": "Replacement String",
            "simpleValueType": true,
            "defaultValue": "[REDACTED]",
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ],
            "help": "Enter string to replace all matches with regex expressions."
          }
        ],
        "enablingConditions": [
          {
            "paramName": "redactValues",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const encodeUriComponent = require('encodeUriComponent'),
      sendHttpRequest = require('sendHttpRequest'),
      setResponseStatus = require('setResponseStatus'),
      makeString = require('makeString'),
      sendHttpGet = require('sendHttpGet');

const queryString = require('getRequestQueryString')();
const requestPath = (data.useOriginalPath == true) ? data.newRequestPath : require('getRequestPath')();
const orgBody = require('getRequestBody')();
const requestMethod = (data.requestMethod === "No Change") ? require('getRequestMethod')() : data.requestMethod;

var postBody = orgBody || null,
    addParams = "";

//rebuild imcoming request URL and add temporary delimiter
var url = data.newServer + requestPath + '?' + queryString;

//eliminate parameters
if (data.deleteParamTable && data.deleteParamTable.length > 0) {
  data.deleteParamTable.forEach(row => {
    const found = url.match("[&?]" + row.paramName+"=[^&$]*");
    if(found) { 
      url = url.replace(found, '');  
    }  
  });
}

//change parameters
if (data.changeParamTable && data.changeParamTable.length > 0) {
  data.changeParamTable.forEach(row => {
    const found = url.match("[&?]"+row.paramName+"=[^&$]*");
    if(found) {
      url = url.replace(found, makeString(found).substring(0,1) + row.paramName+"=" + encodeUriComponent(row.paramValue));
    } else if (row.addParam == "yes") 
      addParams += "&"+row.paramName + "=" + encodeUriComponent(row.paramValue);
  });
}

//add mandatory params if not found in request 
url = url + addParams;


//redact remaining url
if (data.redactValues === true && data.redactPatterns && data.redactPatterns.length > 0) {
  data.redactPatterns.forEach(pat => {
    const redactInfo = url.match(pat.rgx);
    if(redactInfo) url = url.replace(redactInfo, data.redactReplacement);      
  });
}

//send adjusted incoming GA4 request to new property without session_start and first_visit markers
sendHttpRequest(url, {method: requestMethod, timeout: 500,}, postBody).then((result) => {
  setResponseStatus(result.statusCode);
});

data.gtmOnSuccess();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "queryParametersAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "bodyAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "pathAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_response",
        "versionId": "1"
      },
      "param": [
        {
          "key": "writeResponseAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "writeStatusAllowed",
          "value": {
            "type": 8,
            "boolean": true
          }
        },
        {
          "key": "writeHeaderAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 20.6.2022, 21:01:03


