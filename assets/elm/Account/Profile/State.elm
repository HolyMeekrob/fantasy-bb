module Account.Profile.State exposing (init, subscriptions, update)

import Account.Profile.Rest as Rest exposing (fetchUser)
import Account.Profile.Types as Types exposing (Model, Msg)
import Header.State


initialModel : Model
initialModel =
    { user =
        { firstName = "Unknown"
        , lastName = "Unkown"
        , email = "Unknown"
        , bio = "Unknown"
        , avatarUrl = ""
        }
    , header = Header.State.initialModel
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, fetchUser )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                ( { model | header = headerModel }
                , Cmd.map Types.HeaderMsg headerCmd
                )

        Types.SetUser (Err _) ->
            ( initialModel, Cmd.none )

        Types.SetUser (Ok newUser) ->
            ( { model | user = newUser, header = Just newUser }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
