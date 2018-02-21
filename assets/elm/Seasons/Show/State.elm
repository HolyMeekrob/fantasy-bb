module Seasons.Show.State exposing (init, subscriptions, update)

import Seasons.Show.Rest exposing (initialize, updateSeason)
import Seasons.Show.Types as Types
    exposing
        ( Flags
        , FlashMessage
        , FormField
        , Model
        , Msg
        , Season
        )
import Common.Commands exposing (send)
import Common.Navigation exposing (findId)
import Common.Views.Forms exposing (Error)
import Editable
import Header.State
import Time
import Validate exposing (Validator, validate)


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
        , errors = []
        , messages = []
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
            let
                messages =
                    model.messages
                        ++ [ { message = "Season updated"
                             , timer = messageTimer
                             }
                           ]
            in
                { model | messages = messages } ! []

        Types.UpdateFlashMessages _ ->
            let
                messages =
                    List.map tickMessage model.messages
                        |> List.filter isMessageActive
            in
                { model | messages = messages } ! []


messageTimer : Int
messageTimer =
    3


tickMessage : FlashMessage -> FlashMessage
tickMessage message =
    { message | timer = message.timer - 1 }


isMessageActive : FlashMessage -> Bool
isMessageActive message =
    message.timer > 0


subscriptions : Model -> Sub Msg
subscriptions model =
    if (List.isEmpty model.messages) then
        Sub.none
    else
        Time.every Time.second Types.UpdateFlashMessages


getSeason : Model -> Season
getSeason model =
    Editable.value model.season


getTitle : Model -> String
getTitle =
    getSeason >> .title


getStart : Model -> String
getStart =
    getSeason >> .start


validator : Validator (Error FormField) Model
validator =
    Validate.all
        [ Validate.ifBlank getTitle ( Types.Title, "Title is required" )
        , Validate.ifBlank getStart ( Types.Start, "Start date is required" )
        ]
