module Players.Show.View exposing (view)

import Players.Show.Types as Types exposing (FormField, Player, Model, Msg)
import Common.Views exposing (empty, layout, loading)
import Common.Views.Forms exposing (form)
import Common.Views.Text exposing (playerName)
import Editable
import FontAwesome as FA exposing (edit, iconWithOptions)
import Header.View exposing (headerView)
import Html exposing (Html, div, dd, dl, dt, h1, section, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


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
        , h1
            [ class "page-title"
            , onClick Types.EditPlayer
            ]
            [ text "View Player"
            , iconWithOptions
                edit
                FA.Solid
                [ FA.Size FA.ExtraSmall ]
                [ class "clickable" ]
            ]
        , player model
        ]


player : Model -> Html Msg
player model =
    if (Editable.isReadOnly model.player) then
        viewPlayer (Editable.value model.player)
    else
        editPlayer model


viewPlayer : Player -> Html Msg
viewPlayer player =
    let
        name =
            playerName player.firstName player.lastName player.nickname

        hometown =
            Maybe.withDefault "" player.hometown

        birthday =
            Maybe.withDefault "" player.birthday
    in
        div
            []
            [ dl
                []
                (List.concat
                    [ showAttribute "Id" (toString player.id)
                    , showAttribute "Name" name
                    , showAttribute "Hometown" hometown
                    , showAttribute "Birthday" birthday
                    ]
                )
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
