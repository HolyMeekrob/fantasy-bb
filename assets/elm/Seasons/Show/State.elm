module Seasons.Show.State exposing (init, subscriptions, update)

import Seasons.Show.Rest exposing (initialize)
import Seasons.Show.Types as Types exposing (Flags, Model, Msg)
import Common.Commands exposing (send)
import Common.Navigation exposing (findId)
import Header.State


initialModel : String -> Model
initialModel idStr =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , season =
        { id = findId idStr
        , title = ""
        , start = ""
        , players = []
        }
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( initialModel flags.location, send Types.FetchInitialData )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.HeaderMsg headerMsg ->
            let
                ( headerModel, headerCmd ) =
                    Header.State.update headerMsg model.header
            in
                { model | header = headerModel } ! []

        Types.FetchInitialData ->
            model ! [ initialize model.season.id ]

        Types.SetInitialData (Err _) ->
            model ! []

        Types.SetInitialData (Ok ( user, season )) ->
            { model
                | header = Just user
                , season = season
                , pageState = Types.View
            }
                ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
