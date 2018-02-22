module Header.State exposing (..)

import Header.Rest exposing (logOut)
import Header.Types as Types exposing (Model, Msg, Notification)
import Common.Navigation exposing (navigate)
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
                    model.notifications ++ (addMessage message)
            in
                { model | notifications = notifications } ! []

        Types.UpdateNotifications _ ->
            let
                notifications =
                    model.notifications
                        |> List.map tickMessage
                        |> List.filter isMessageActive
            in
                { model | notifications = notifications } ! []


messageTimer : Int
messageTimer =
    3


addMessage : String -> List Notification
addMessage message =
    List.singleton { message = message, timer = messageTimer }


tickMessage : Notification -> Notification
tickMessage message =
    { message | timer = message.timer - 1 }


isMessageActive : Notification -> Bool
isMessageActive message =
    message.timer > 0


subscriptions : Model -> Sub Msg
subscriptions model =
    if (List.isEmpty model.notifications) then
        Sub.none
    else
        Time.every Time.second Types.UpdateNotifications
