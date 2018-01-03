module Account.Profile exposing (main)

import Account.Profile.State as State exposing (init, subscriptions, update)
import Account.Profile.Types as Types exposing (Model, Msg)
import Account.Profile.View as View exposing (view)
import Html exposing (program)


main : Program Never Model Msg
main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
