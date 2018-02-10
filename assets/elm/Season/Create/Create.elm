module Season.Create exposing (main)

import Html exposing (program)
import Season.Create.State exposing (init, update, subscriptions)
import Season.Create.Types exposing (Model, Msg)
import Season.Create.View exposing (view)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
