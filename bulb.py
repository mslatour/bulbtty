#!/usr/bin/python
import argparse
import httplib
import json
import sys
import base64

BULB_DEFAULT_HOST = "127.0.0.1"
BULB_DEFAULT_PORT = 8000

def get_authorization_token(username, password):
  return "N4JBasic %s" % (base64.b64encode(username+":"+password),)

def show_idea_list(ideas, compact):
  if compact:
    for idea in ideas:
      str = ''
      for attr in idea:
        str += "[%s]=%s " % (attr,idea[attr])
      print '|',str
  else :
    for idea in ideas:
      print '#'*20
      for attr in idea:
        print '|',attr,':',idea[attr]

parser = argparse.ArgumentParser(description='Command-line interface to project bulb.')
parser.add_argument('-u', '--user', metavar='username', nargs=1, help='Your projectbulb username')
parser.add_argument('-p', '--password', metavar='password', nargs=1,  help='Your projectbulb password')
parser.add_argument('-c', '--compact', action='store_true', help='Keep the output compact')
parser.add_argument('command', choices=['list','create','get','connect','neighbors','delete'], help='Command')
parser.add_argument('params', nargs='*')
args = parser.parse_args()

bulb = httplib.HTTPConnection(BULB_DEFAULT_HOST, BULB_DEFAULT_PORT)

if args.command == 'list':
  bulb.request("GET", "/idea/")
  ret = bulb.getresponse()
  if ret.status == 200:
    show_idea_list(json.loads(ret.read()), args.compact)
  else :
    print "Error: Server returned %d %s" % (ret.status, ret.reason)
elif args.command == 'get':
  try :
    ideaId = int(args.params[0])
  except :
    print "Error: Command `get' takes exactly one integer, the ideaId, as parameter"
    sys.exit()

  bulb.request("GET", "/idea/"+str(ideaId)+"/")
  ret = bulb.getresponse()
  if ret.status == 200:
    show_idea_list(json.loads(ret.read()), args.compact)
  else :
    print "Error: Server returned %d %s" % (ret.status, ret.reason)
elif args.command == 'create':
  if len(args.params) == 1:
    bulb.request("POST", "/idea/", args.params[0],{"Content-Type": "application/json", "Accept":"application/json", "Authorization" : get_authorization_token(args.user[0], args.password[0])});
    ret = bulb.getresponse()
    if ret.status == 200:
      idea = json.loads(ret.read())
      print "Stored idea %d: \"%s\"" % (idea['id'], idea['title'])
    else :
      print "Error: Server returned %d %s" % (ret.status, ret.reason)
  else :
    print "Error: No interactive support at the moment"
else :
  print "Error: Unsupported command at this moment"
