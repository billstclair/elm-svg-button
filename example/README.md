This directory contains an example of using the `Svg.Button` module.

# Running the example

You can run it with `elm reactor` from the main `elm-svg-button` directory (not this `example` directory):

    $ cd .../elm-svg-button
    $ elm reactor
    
Then aim your browser at http://localhost:8000/example/Example.elm.

The example displays a "Count", and has four buttons, "Increment", "Repeating Increment", "Repeating Decrement", and "Decrement". The "Increment" & "Decrement" buttons change the count once per click. The "Repeating" buttons change the count when you press them, and then, after a 0.5 second delay, change it again every 0.1 seconds.

The example will work in a touch screen browser, but you'll need to start `elm reactor` differently:

    $ elm reactor -a 0.0.0.0

Then you can aim your mobile device's browser at http://n.n.n.n:8000/example/Example.elm, where `n.n.n.n` is your computer's IP address on your local network (from e.g. `ifconfig en0` in MacOS, `ip addr` in Linux, or some control panel in Windows).

# Coding repeating buttons

The top-level [`README`](../) shows how to code a non-repeating button. Repeating buttons take a little more work, since they have changing state that you need to store in your `Model`, and you need to subscribe to `Time` updates.

Our `Button.Msg` has a more complicated state, including both the operation and a button identifier. If you have more buttons, you may prefer to store them in a `Dictionary` or an `Array`.

    type Operation
        = Increment
        | Decrement

    type alias Model =
        { cnt : Int
        , incrementButton : Button ()
        , decrementButton : Button ()
        , subscription : Maybe ( Float, Button.Msg, Operation )
        }

The example splits button messages into simple ones, containing only an `Operation` for state, and more general ones, containing `(Operation, WhichButton)` for state:

    type Msg
        = SimpleButtonMsg Button.Msg Operation
        | ButtonMsg Button.Msg Operation

And here's how those two stateful buttons are initialized:

    init : ( Model, Cmd Msg )
    init =
        ( { cnt = 0
          , incrementButton =
              Button.repeatingButton
                  Button.normalRepeatTime
                  buttonSize
                  ()
          , decrementButton =
              Button.repeatingButton
                  Button.normalRepeatTime
                  buttonSize
                  ()
          , subscription = Nothing
          }
        , Cmd.none
        )
            
The update function needs to handle two cases for the repeating buttons, one of them provides information for subscriptions, and the other provides clicks and updated button state.

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            ...
            ButtonMsg m operation ->
                let
                    button =
                        case operation of
                            Increment ->
                                model.incrementButton

                            Decrement ->
                                model.decrementButton
                in
                case Button.checkSubscription m button of
                    Just ( time, m2 ) ->
                        ( { model
                             | subscription =
                                 if time <= 0 then
                                     Nothing
                                 else
                                     Just ( time, m2, operation )
                          }
                        , Cmd.none
                        )

                    Nothing ->
                        let
                            ( isClick, button2, cmd ) =
                                Button.update (bm -> ButtonMsg bm operation)
                                    m
                                    button

                            mdl =
                            case operation of
                                Increment ->
                                    { model | incrementButton = button2 }

                                Decrement ->
                                    { model | decrementButton = button2 }
                        in
                        (operate isClick operation mdl, cmd)

Finally, the subscription information is used to subscribe to `Time` updates:

    subscriptions : Model -> Sub Msg
    subscriptions model =
        case model.subscription of
            Nothing ->
                Sub.none

            Just ( time, msg, operation ) ->
                Time.every time (\_ -> ButtonMsg msg operation)
