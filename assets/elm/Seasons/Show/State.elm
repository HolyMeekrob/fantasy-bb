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
                { model | header = headerModel } ! []

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
                newStart =
                    Date.fromString start
                        |> Result.toMaybe

                updatedSeason =
                    Editable.map
                        (\season -> { season | start = newStart })
                        model.season
            in
                { model | season = updatedSeason } ! []

        Types.SubmitForm ->
            let
                validationErrors =
                    Validate.validate validator model
            in
                if (List.isEmpty validationErrors) then
                    let
                        newSeason =
                            Editable.save model.season
                    in
                        { model | season = newSeason }
                            ! [ updateSeason (Editable.value newSeason) ]
                else
                    { model | errors = validationErrors } ! []

        Types.SeasonUpdated (Err _) ->
            let
                newModel =
                    { model
                        | errors =
                            [ ( Types.Summary, "Error creating season" ) ]
                    }
            in
                newModel ! []

        Types.SeasonUpdated (Ok season) ->
            model ! [ addNotification "Season successfully saved" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map Types.HeaderMsg (Header.State.subscriptions model.header)


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
