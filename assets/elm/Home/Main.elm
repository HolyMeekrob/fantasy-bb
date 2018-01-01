module Home exposing (..)

import Home.State exposing (init, update, subscriptions)
import Home.Types as Types exposing (Model, Msg)
import Home.View as View exposing (view)
import Html exposing (Html, div, header, main_, program, text)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
