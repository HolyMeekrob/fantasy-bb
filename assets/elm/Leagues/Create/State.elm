module Leagues.Create.State exposing (init, subscriptions, update)

import Common.Commands exposing (send)
import Common.Navigation exposing (navigate)
import Common.Rest exposing (fetch, userRequest)
import Common.Views.Forms exposing (Error)
import Header.State
import Leagues.Create.Types as Types exposing (Model, Msg)
import Leagues.Create.Rest exposing (createLeague)
import Validate exposing (Validator)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , name = ""
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
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just newUser }
            in
                { model | header = headerModel, pageState = Types.Loaded } ! []

        Types.SetName name ->
            { model | name = name } ! []

        Types.SubmitForm ->
            let
                validationErrors =
                    Validate.validate validator model
            in
                if (List.isEmpty validationErrors) then
                    model ! [ createLeague model ]
                else
                    { model | errors = validationErrors } ! []

        Types.LeagueCreated (Err _) ->
            { model | errors = [ ( Types.Summary, "Error creating league" ) ] }
                ! []

        Types.LeagueCreated (Ok newLeague) ->
            let
                url =
                    "/leagues/" ++ (toString newLeague.id)
            in
                model ! [ navigate url ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


validator : Validator (Error Types.FormField) Model
validator =
    Validate.all
        [ Validate.ifBlank
            .name
            ( Types.Name, "Name is required" )
        ]
