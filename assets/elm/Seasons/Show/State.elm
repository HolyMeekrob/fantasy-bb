module Seasons.Show.State exposing (init, subscriptions, update)

import Seasons.Show.Types as Types exposing (Model, Msg)
import Common.Commands exposing (send)
import Common.Rest exposing (fetchUser)
import Header.State


initialModel : Model
initialModel =
    { header = Header.State.initialModel
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
                { model | header = headerModel }
                    ! [ Cmd.map Types.HeaderMsg headerCmd ]

        Types.FetchUser ->
            model ! [ fetchUser Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            { model | header = Just newUser } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
