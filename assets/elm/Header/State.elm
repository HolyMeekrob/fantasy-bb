module Header.State exposing (..)

import Header.Rest exposing (updateUser, logOut)
import Header.Types as Types exposing (Model, Msg)
import Utils.Navigation exposing (navigate)


initialModel : Model
initialModel =
    { user =
        { firstName = ""
        , lastName = ""
        , avatarUrl = ""
        }
    , isLoggedIn = False
    }


initialize : Cmd Msg
initialize =
    updateUser


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.SetUser (Err _) ->
            ( initialModel, Cmd.none )

        Types.SetUser (Ok user) ->
            ( { model | user = user, isLoggedIn = True }, Cmd.none )

        Types.RequestLogOut ->
            ( model, logOut )

        Types.LogOut (Err _) ->
            ( model, Cmd.none )

        Types.LogOut (Ok redirectUrl) ->
            ( model, navigate redirectUrl )
