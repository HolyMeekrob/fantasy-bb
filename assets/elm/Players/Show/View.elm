module Players.Show.View exposing (view)

import Players.Show.Types as Types exposing (FormField, Player, Model, Msg)
import Common.Date exposing (dateToString)
import Common.Views exposing (empty, layout, loading, titleWithEdit)
import Common.Views.Forms exposing (form)
import Common.Views.Text exposing (playerName)
import Editable
import Header.View exposing (headerView)
import Html exposing (Html, div, dd, dl, dt, h1, section, text)


view : Model -> Html Msg
view model =
    layout
        (headerView Types.HeaderMsg model.header)
        (primaryView model)


primaryView : Model -> Html Msg
primaryView model =
    section
        []
        [ loadingOverlay model
        , titleWithEdit
            "View Player"
            Types.EditPlayer
            (model.userCanEdit && (not <| isEditing model))
        , player model
        ]


player : Model -> Html Msg
player model =
    if (isEditing model) then
        editPlayer model
    else
        viewPlayer (Editable.value model.player)


viewPlayer : Player -> Html Msg
viewPlayer player =
    let
        name =
            playerName player.firstName player.lastName player.nickname

        hometown =
            Maybe.withDefault "" player.hometown

        birthday =
            Maybe.map dateToString player.birthday
                |> Maybe.withDefault ""
    in
        div
            []
            [ dl
                []
              <|
                List.concat
                    [ showAttribute "Name" name
                    , showAttribute "Hometown" hometown
                    , showAttribute "Birthday" birthday
                    ]
            ]


showAttribute : String -> String -> List (Html Msg)
showAttribute title description =
    [ dt
        []
        [ text title ]
    , dd
        []
        [ text description ]
    ]


editPlayer : Model -> Html Msg
editPlayer model =
    let
        player =
            Editable.value model.player
    in
        div
            []
            [ form
                ( "Save", Types.SubmitForm )
                [ ( "Cancel", Types.CancelEdit ) ]
                (errors Types.Summary model)
                [ { id = "player-first-name"
                  , type_ = "text"
                  , label = "First Name"
                  , placeholder = "First name"
                  , value = player.firstName
                  , onInput = Types.SetFirstName
                  , isRequired = True
                  , errors = errors Types.FirstName model
                  }
                , { id = "player-last-name"
                  , type_ = "text"
                  , label = "Last Name"
                  , placeholder = "Last name"
                  , value = player.lastName
                  , onInput = Types.SetLastName
                  , isRequired = True
                  , errors = errors Types.LastName model
                  }
                , { id = "player-nickname"
                  , type_ = "text"
                  , label = "Nickname"
                  , placeholder = "Nickname"
                  , value = Maybe.withDefault "" player.nickname
                  , onInput = Types.SetNickname
                  , isRequired = False
                  , errors = errors Types.Nickname model
                  }
                , { id = "player-hometown"
                  , type_ = "text"
                  , label = "Hometown"
                  , placeholder = "Hometown"
                  , value = Maybe.withDefault "" player.hometown
                  , onInput = Types.SetHometown
                  , isRequired = False
                  , errors = errors Types.Hometown model
                  }
                , { id = "player-birthday"
                  , type_ = "date"
                  , label = "Birthday"
                  , placeholder = "Birthday"
                  , value =
                        Maybe.map dateToString player.birthday
                            |> Maybe.withDefault ""
                  , onInput = Types.SetBirthday
                  , isRequired = False
                  , errors = errors Types.Birthday model
                  }
                ]
            ]


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty


errors : FormField -> Model -> List String
errors field model =
    let
        fieldMatches =
            \( errorField, _ ) -> field == errorField
    in
        List.filter fieldMatches model.errors
            |> List.map Tuple.second


isEditing : Model -> Bool
isEditing model =
    Editable.isEditable model.player
