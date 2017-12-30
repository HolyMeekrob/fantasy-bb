module Header.State exposing (..)

import Header.Rest exposing (updateUser)
import Header.Types as Types exposing (Model, Msg)


initialModel : Model
initialModel =
    { user =
        { firstName = ""
        , lastName = ""
        , avatarUrl = ""
        }
    }


initialize : Cmd Msg
initialize =
    updateUser


update : Msg -> Model -> Model
update msg model =
    case msg of
        Types.SetUser (Err _) ->
            initialModel

        Types.SetUser (Ok user) ->
            { model | user = user }
