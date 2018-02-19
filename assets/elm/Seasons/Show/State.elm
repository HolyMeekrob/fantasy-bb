module Seasons.Show.State exposing (init, subscriptions, update)

import Seasons.Show.Rest exposing (initialize)
import Seasons.Show.Types as Types exposing (Flags, Model, Msg)
import Common.Commands exposing (send)
import Common.Navigation exposing (findId)
import Editable
import Header.State


initialModel : String -> Model
initialModel idStr =
    let
        season =
            { id = findId idStr
            , title = ""
            , start = ""
            , players = []
            }
    in
        { header = Header.State.initialModel
        , pageState = Types.Loading
        , season = Editable.ReadOnly season
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
            model ! [ initialize <| .id (Editable.value model.season) ]

        Types.SetInitialData (Err _) ->
            model ! []

        Types.SetInitialData (Ok ( user, season )) ->
            { model
                | header = Just user
                , pageState = Types.Loaded
                , season = Editable.ReadOnly season
            }
                ! []

        Types.EditSeason ->
            { model | season = Editable.edit model.season } ! []

        Types.CancelEdit ->
            { model | season = Editable.cancel model.season } ! []

        Types.SetTitle title ->
            let
                updatedSeason =
                    Editable.map
                        (\season -> { season | title = title })
                        model.season
            in
                { model | season = updatedSeason } ! []

        Types.SetStart start ->
            let
                updatedSeason =
                    Editable.map
                        (\season -> { season | start = start })
                        model.season
            in
                { model | season = updatedSeason } ! []

        Types.SubmitForm ->
            { model | season = Editable.save model.season } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
