module Seasons.Show.State exposing (init, subscriptions, update)

import Seasons.Show.Rest exposing (initialize, updateSeason)
import Seasons.Show.Types as Types
    exposing
        ( Flags
        , FormField
        , Model
        , Msg
        , Season
        )
import Common.Commands exposing (send)
import Common.Navigation exposing (findId)
import Common.Views.Forms exposing (Error)
import Date exposing (Date)
import Editable
import Header.State
import Header.Types
import Task
import Validate exposing (Validator, validate)


initialModel : String -> Model
initialModel idStr =
    let
        season =
            { id = findId idStr
            , title = ""
            , start = Nothing
            , players = []
            }
    in
        { header = Header.State.initialModel
        , pageState = Types.Loading
        , season = Editable.ReadOnly season
        , errors = []
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
                { model | header = headerModel }
                    ! [ Cmd.map Types.HeaderMsg headerCmd ]

        Types.FetchInitialData ->
            model ! [ initialize <| .id (Editable.value model.season) ]

        Types.SetInitialData (Err _) ->
            model ! []

        Types.SetInitialData (Ok ( user, season )) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just user }
            in
                { model
                    | header = headerModel
                    , pageState = Types.Loaded
                    , season = Editable.ReadOnly season
                }
                    ! []

        Types.EditSeason ->
            { model | season = Editable.edit model.season } ! []

        Types.CancelEdit ->
            { model
                | errors = []
                , season = Editable.cancel model.season
            }
                ! []

        Types.SetTitle title ->
            updateSeasonField
                (\season -> { season | title = title })
                model

        Types.SetStart start ->
            let
                newStart =
                    Date.fromString start
                        |> Result.toMaybe
            in
                updateSeasonField
                    (\season -> { season | start = newStart })
                    model

        Types.SubmitForm ->
            let
                validationErrors =
                    validate validator model
            in
                if (List.isEmpty validationErrors) then
                    { model
                        | pageState = Types.Loading
                        , errors = []
                    }
                        ! [ updateSeason (Editable.value model.season) ]
                else
                    { model | errors = validationErrors } ! []

        Types.SeasonUpdated (Err _) ->
            let
                newModel =
                    { model
                        | pageState = Types.Loaded
                        , errors =
                            [ ( Types.Summary, "Error updating season" ) ]
                    }
            in
                newModel ! []

        Types.SeasonUpdated (Ok _) ->
            { model
                | pageState = Types.Loaded
                , season = Editable.save model.season
            }
                ! [ addNotification "Season successfully saved" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map Types.HeaderMsg (Header.State.subscriptions model.header)


updateSeasonField : (Season -> Season) -> Model -> ( Model, Cmd Msg )
updateSeasonField func model =
    let
        updatedSeason =
            Editable.map func model.season
    in
        { model | season = updatedSeason } ! []


getSeason : Model -> Season
getSeason model =
    Editable.value model.season


getTitle : Model -> String
getTitle =
    getSeason >> .title


getStart : Model -> Maybe Date
getStart =
    getSeason >> .start


validator : Validator (Error FormField) Model
validator =
    Validate.all
        [ Validate.ifBlank getTitle ( Types.Title, "Title is required" )
        , Validate.ifNothing getStart ( Types.Start, "Start date is required" )
        ]


addNotification : String -> Cmd Msg
addNotification message =
    Task.perform
        (\msg -> Types.HeaderMsg (Header.Types.AddNotification msg))
        (Task.succeed message)
