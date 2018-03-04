module Players.Create.View exposing (view)

import Common.Date exposing (dateToString)
import Common.Views exposing (empty, layout, loading, title)
import Common.Views.Forms exposing (form)
import Header.View exposing (headerView)
import Html exposing (Html, div, section)
import Players.Create.Types as Types exposing (FormField, Model, Msg)


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
        , title "Create Player"
        , div
            []
            [ form
                ( "Submit", Types.SubmitForm )
                []
                (errors Types.Summary model)
                [ { id = "first-name"
                  , type_ = "text"
                  , label = "First Name"
                  , placeholder = "First name"
                  , value = model.player.firstName
                  , onInput = Types.SetFirstName
                  , isRequired = True
                  , errors = errors Types.FirstName model
                  }
                , { id = "player-last-name"
                  , type_ = "text"
                  , label = "Last Name"
                  , placeholder = "Last name"
                  , value = model.player.lastName
                  , onInput = Types.SetLastName
                  , isRequired = True
                  , errors = errors Types.LastName model
                  }
                , { id = "player-nickname"
                  , type_ = "text"
                  , label = "Nickname"
                  , placeholder = "Nickname"
                  , value = Maybe.withDefault "" model.player.nickname
                  , onInput = Types.SetNickname
                  , isRequired = False
                  , errors = errors Types.Nickname model
                  }
                , { id = "player-hometown"
                  , type_ = "text"
                  , label = "Hometown"
                  , placeholder = "Hometown"
                  , value = Maybe.withDefault "" model.player.hometown
                  , onInput = Types.SetHometown
                  , isRequired = False
                  , errors = errors Types.Hometown model
                  }
                , { id = "player-birthday"
                  , type_ = "date"
                  , label = "Birthday"
                  , placeholder = "Birthday"
                  , value =
                        Maybe.map dateToString model.player.birthday
                            |> Maybe.withDefault ""
                  , onInput = Types.SetBirthday
                  , isRequired = False
                  , errors = errors Types.Birthday model
                  }
                ]
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
