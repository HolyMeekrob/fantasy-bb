module Season.Create.State exposing (init, subscriptions, update)

import Season.Create.Types as Types exposing (Error, Model, Msg)
import Common.Commands exposing (send)
import Common.Rest exposing (fetchUser)
import Header.State
import Date exposing (Date)
import Validate exposing (Validator, validate)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , name = ""
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
            model ! [ fetchUser Types.SetUser ]

        Types.SetUser (Err _) ->
            initialModel ! []

        Types.SetUser (Ok newUser) ->
            { model | header = Just newUser } ! []

        Types.SetName name ->
            { model | name = name } ! []

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
                { model | errors = validationErrors } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


validator : Validator Error Model
validator =
    Validate.all
        [ Validate.ifBlank .name ( Types.Name, "Name is required" )
        , Validate.ifNothing .start ( Types.Start, "Start date is required" )
        ]
