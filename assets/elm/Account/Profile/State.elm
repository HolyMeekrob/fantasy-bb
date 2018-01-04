module Account.Profile.State exposing (init, subscriptions, update)

import Account.Profile.Rest as Rest exposing (fetchUser)
import Account.Profile.Types as Types exposing (Model, Msg)
import Header.State
import Common.Commands exposing (send)


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
    , pageState = Types.Loading
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, send Types.FetchUser )


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

        Types.FetchUser ->
            ( { model | pageState = Types.Loading }, fetchUser )

        Types.SetUser (Err _) ->
            ( initialModel, Cmd.none )

        Types.SetUser (Ok newUser) ->
            ( { model
                | user = newUser
                , header = Just newUser
                , pageState = Types.Loaded
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
