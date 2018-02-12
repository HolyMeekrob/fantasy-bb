module Season.Create.State exposing (init, subscriptions, update)

import Common.Rest exposing (fetchUser)
import Season.Create.Types as Types exposing (Model, Msg)
import Header.State
import Common.Commands exposing (send)


initialModel : Model
initialModel =
    { header = Header.State.initialModel
    , name = ""
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

        Types.SubmitForm ->
            model ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
