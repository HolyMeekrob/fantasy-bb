module Seasons.Create.State exposing (init, subscriptions, update)

import Seasons.Create.Types as Types exposing (Error, Model, Msg)
import Seasons.Create.Rest exposing (createSeason)
import Common.Commands exposing (send)
import Common.Rest exposing (fetch, userRequest)
import Header.State
import Date exposing (Date)
import Validate exposing (Validator, validate)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , title = ""
    , start = Nothing
    , errors = []
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
            model ! [ fetch userRequest Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            { model | header = Just newUser, pageState = Types.Loaded } ! []

        Types.SetTitle title ->
            { model | title = title } ! []

        Types.SetStart dateStr ->
            case Date.fromString dateStr of
                Ok newDate ->
                    { model | start = Just newDate } ! []

                Err _ ->
                    { model | start = Nothing } ! []

        Types.SubmitForm ->
            let
                validationErrors =
                    Validate.validate validator model
            in
                if (List.isEmpty validationErrors) then
                    model ! [ createSeason model ]
                else
                    { model | errors = validationErrors } ! []

        Types.SeasonCreated (Err _) ->
            let
                newModel =
                    { model
                        | errors =
                            [ ( Types.Summary, "Error creating season" ) ]
                    }
            in
                newModel ! []

        Types.SeasonCreated (Ok season) ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


validator : Validator Error Model
validator =
    Validate.all
        [ Validate.ifBlank .title ( Types.Title, "Title is required" )
        , Validate.ifNothing .start ( Types.Start, "Start date is required" )
        ]
