module Players.Show.View exposing (view)

import Players.Show.Types as Types exposing (Player, Model, Msg)
import Common.Views exposing (empty, layout, loading)
import Common.Views.Text exposing (playerName)
import Header.View exposing (headerView)
import Html exposing (Html, div, dd, dl, dt, h1, section, text)
import Html.Attributes exposing (class)


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
            [ class "page-title" ]
            [ text "View Player" ]
        , playerInfo model.player
        ]


playerInfo : Player -> Html Msg
playerInfo player =
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


loadingOverlay : Model -> Html Msg
loadingOverlay model =
    case model.pageState of
        Types.Loading ->
            loading

        _ ->
            empty
