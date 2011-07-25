#
#
#            Nimrod's Runtime Library
#        (c) Copyright 2011 Alex Mitchell
#
#    See the file "copying.txt", included in this
#    distribution, for details about the copyright.
#

## :Author: Alex Mitchell
##
## This module implements an event system that is not dependant on external
## graphical toolkits. It was originally called ``NimEE`` because 
## it was inspired by Ptyhon's PyEE module.

type
  TEventArgs* = object of TObject ## Base object for event arguments
                                  ## that are passed to callback functions.
  TEventHandler = tuple[name: string, handlers: seq[proc(e:TEventArgs)]]
  PEventHandler* = ref TEventHandler ## An eventhandler for an event.

type
  TEventEmitter = object {.pure, final.}
    s: seq[PEventHandler]
  PEventEmitter* = ref TEventEmitter ## An object that fires events and 
                                     ## holds event handlers for an object.
  EInvalidEvent* = object of EInvalidValue
    
proc newEventHandler*(name: string): PEventHandler =
  ## Initializes an EventHandler with the specified name and returns it.
  new(result)
  result.handlers = @[]
  result.name = name

proc addHandler*(handler: PEventHandler, func: proc(e: TEventArgs)) =
  ## Adds the callback to the specified event handler.
  handler.handlers.add(func)

proc removeHandler*(handler: PEventHandler, func: proc(e: TEventArgs)) =
  ## Removes the callback from the specified event handler.
  for i in countup(0, len(handler.handlers) -1):
    if func == handler.handlers[i]:
      handler.handlers.del(i)
      break
    
proc clearHandlers*(handler: PEventHandler) =
  ## Clears all of the callbacks from the event handler.
  setLen(handler.handlers, 0)

proc getEventhandler(emitter: PEventEmitter, event: string): int =
  for k in 0..high(emitter.s):
    if emitter.s[k].name == event: return k
  return -1

proc on*(emitter: PEventEmitter, event: string, func: proc(e: TEventArgs)) =
  ## Assigns a event handler with the specified callback. If the event
  ## doesn't exist, it will be created.
  var i = getEventHandler(emitter, event)
  if i < 0:
    var eh = newEventHandler(event)
    addHandler(eh, func)
    emitter.s.add(eh)
  else:
    addHandler(emitter.s[i], func)
  
proc emit*(emitter: PEventEmitter, eventhandler: PEventHandler, 
           args: TEventArgs) =
  ## Fires an event handler with specified event arguments.
  for func in items(eventhandler.handlers): func(args)

proc emit*(emitter: PEventEmitter, event: string, args: TEventArgs) =
  ## Fires an event handler with specified event arguments.
  var i = getEventHandler(emitter, event)
  if i >= 0:
    emit(emitter, emitter.s[i], args)
  else:
    raise newException(EInvalidEvent, "invalid event: " & event)

proc newEventEmitter*(): PEventEmitter =
  ## Creates and returns a new EventEmitter.
  new(result)
  result.s = @[]
