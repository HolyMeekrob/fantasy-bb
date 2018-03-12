module Leagues.Create.State exposing (init, subscriptions, update)

import Common.Navigation exposing (navigate)
import Common.Views.Forms exposing (Error)
import Header.State
import Leagues.Create.Types as Types exposing (Model, Msg, Season)
import Leagues.Create.Rest exposing (createLeague, initialize)
import Validate exposing (Validator)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , name = ""
    , season = Nothing
    , possibleSeasons = []
    , errors = []
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, initialize )


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

        Types.SetInitialData (Err _) ->
            let
                errorMessage =
                    "Error initializing page"
            in
                { model | pageState = Types.Error errorMessage } ! []

        Types.SetInitialData (Ok ( user, seasons )) ->
            if (List.isEmpty seasons) then
                { model
                    | pageState = Types.Error "There are no upcoming seasons"
                }
                    ! []
            else
                let
                    header =
                        model.header

                    headerModel =
                        { header | user = Just user }
                in
                    { model
                        | header = headerModel
                        , pageState = Types.Loaded
                        , season = initialSeason seasons
                        , possibleSeasons = seasons
                    }
                        ! []

        Types.SetName name ->
            { model | name = name } ! []

        Types.SetSelectedSeason season ->
            { model | season = season } ! []

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

        Types.LeagueCreated (Ok id) ->
            let
                url =
                    "/leagues/" ++ (toString id)
            in
                model ! [ navigate url ]


initialSeason : List Season -> Maybe Season
initialSeason seasons =
    if (List.length seasons > 1) then
        Nothing
    else
        List.head (seasons)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


validator : Validator (Error Types.FormField) Model
validator =
    Validate.all
        [ Validate.ifBlank .name ( Types.Name, "Name is required" )
        , Validate.ifNothing .season ( Types.Summary, "Season is required" )
        ]
