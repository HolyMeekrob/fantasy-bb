module Header.State exposing (..)

import Header.Rest exposing (logOut)
import Header.Types as Types exposing (Model, Msg)
import Utils.Navigation exposing (navigate)


initialModel : Model
initialModel =
    Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.RequestLogOut ->
            ( model, logOut )

        Types.LogOut (Err _) ->
            ( model, Cmd.none )

        Types.LogOut (Ok redirectUrl) ->
            ( model, navigate redirectUrl )
