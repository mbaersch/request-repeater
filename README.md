# Request Repeater

**Custom Tag Template for Server-Side Google Tag Manager**

Change and forward incoming requests to a new endpoint 

![Template Status](https://img.shields.io/badge/Community%20Template%20Gallery%20Status-submitted-orange) ![Repo Size](https://img.shields.io/github/repo-size/mbaersch/request-repeater) ![License](https://img.shields.io/github/license/mbaersch/request-repeater)

---

## >Usage
Whenever this tag is triggered, it forwards an incoming request to a new destination. The request path can be altered as well as the request method. 

All parameters can be either deleted (by key), changed if present or added if not. The remaining url can optionally be redacted using regular expressions. The resulting request is sent by the tag after all defined parameter changes.

If a POST payload contains additional parameters, those can be processed in the same way if needed. 
