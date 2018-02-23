module Header.State exposing (..)

import Header.Rest exposing (logOut)
import Header.Types as Types exposing (Model, Msg)
import Common.Navigation exposing (navigate)
import Process
import Task
import Time


initialModel : Model
initialModel =
    { user = Nothing
    , notifications = []
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Types.RequestLogOut ->
            model ! [ logOut ]

        Types.LogOut (Err _) ->
            model ! []

        Types.LogOut (Ok redirectUrl) ->
            model ! [ navigate redirectUrl ]

        Types.AddNotification message ->
            let
                notifications =
                    model.notifications ++ List.singleton message
            in
                { model | notifications = notifications } ! [ scheduleNotification ]

        Types.ClearOldestNotification ->
            let
                notifications =
                    List.drop 1 model.notifications
            in
                { model | notifications = notifications } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


messageTimer : Float
messageTimer =
    3


scheduleNotification : Cmd Msg
scheduleNotification =
    Process.sleep
        (Time.second * messageTimer)
        |> Task.map (always Types.ClearOldestNotification)
        |> Task.perform identity
