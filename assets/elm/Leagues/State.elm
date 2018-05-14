module Leagues.State exposing (init, subscriptions, update)

import Header.State
import Leagues.Rest exposing (initialize)
import Leagues.Types as Types exposing (Model, Msg)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , leagues =
        { upcoming = []
        , current = []
        , complete = []
        }
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
            model ! []

        Types.SetInitialData (Ok ( user, leagueSummary )) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just user }
            in
                { model
                    | header = headerModel
                    , leagues = leagueSummary
                    , pageState = Types.Loaded
                }
                    ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
