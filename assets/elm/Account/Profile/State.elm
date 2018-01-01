module Account.Profile.State exposing (init, subscriptions, update)

import Account.Profile.Rest as Rest exposing (fetchUser)
import Account.Profile.Types as Types exposing (Model, Msg)


initialModel : Model
initialModel =
    { user =
        { firstName = "Unknown"
        , lastName = "Unkown"
        , email = "Unknown"
        , bio = "Unknown"
        , avatarUrl = ""
        }
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchUser )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.SetUser (Err _) ->
            ( initialModel, Cmd.none )

        Types.SetUser (Ok newUser) ->
            ( { model | user = newUser }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
