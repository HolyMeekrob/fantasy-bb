module Teams.Show.State exposing (init, subscriptions, update)

import Common.Commands exposing (send)
import Common.Navigation exposing (findId)
import Header.State
import Teams.Show.Rest exposing (initialize)
import Teams.Show.Types as Types exposing (Flags, Model, Msg)


initialModel : String -> Model
initialModel idStr =
    { header = Header.State.initialModel
    , pageState = Types.Loading
    , team =
        { id = findId idStr
        , name = ""
        , ownerId = 0
        , ownerName = ""
        , points = 0
        , players = []
        , canEdit = False
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
                ( { model | header = headerModel }
                , (Cmd.map Types.HeaderMsg headerCmd)
                )

        Types.FetchInitialData ->
            ( model, initialize model.team.id )

        Types.SetInitialData (Err _) ->
            ( model, Cmd.none )

        Types.SetInitialData (Ok ( user, team )) ->
            let
                header =
                    model.header

                headerModel =
                    { header | user = Just user }
            in
                ( { model
                    | header = headerModel
                    , pageState = Types.Loaded
                    , team = team
                  }
                , Cmd.none
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map Types.HeaderMsg (Header.State.subscriptions model.header)
