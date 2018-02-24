module Header.State exposing (..)

import Header.Rest exposing (logOut)
import Header.Types as Types exposing (Model, Msg, Notification)
import Common.Navigation exposing (navigate)
import List.Extra exposing (find, setAt)
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
                    model.notifications ++ createNotification message
            in
                { model | notifications = notifications }
                    ! [ scheduleNotificationRemoval ]

        Types.CloseOldestNotification ->
            let
                oldest =
                    List.indexedMap (,) model.notifications
                        |> find (\( i, n ) -> n.closed == False)

                updatedNotifications =
                    case oldest of
                        Nothing ->
                            model.notifications

                        Just ( index, n ) ->
                            setAt
                                index
                                { n | closed = True }
                                model.notifications
            in
                { model | notifications = updatedNotifications } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


createNotification : String -> List Notification
createNotification message =
    List.singleton { message = message, closed = False }


messageTimer : Float
messageTimer =
    3


scheduleNotificationRemoval : Cmd Msg
scheduleNotificationRemoval =
    Process.sleep
        (Time.second * messageTimer)
        |> Task.map (always Types.CloseOldestNotification)
        |> Task.perform identity
