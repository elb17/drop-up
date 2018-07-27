module Main exposing (..)

import DropUp
import Html
import Html.Attributes as Attr


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    { data : List (String, Bool)
    , dropdownState : DropUp.State
    }


init : ( Model, Cmd Msg )
init =
    ( { data = [ ("Option 1", False), ("Option 2", False), ("Option 3", False)]
      , dropdownState = DropUp.initialState
      }
    , Cmd.none
    )



-- Update


type Msg
    = SetDropDownState DropUp.State
    | SetItems (List (String, Bool))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetDropDownState newState ->
            ( { model | dropdownState = newState }
            , Cmd.none
            )
        SetItems newList ->
            ( { model | data = newList }
            , Cmd.none
            )



-- VIEW


view : Model -> Html.Html Msg
view { data, dropdownState } =
    Html.div []
        [ Html.div [ Attr.style [ ( "margin", "200px auto" ), ( "width", "200px" ) ] ]
            [ DropUp.view
                config
                dropdownState
                data
            ]
        ]


config : DropUp.Config String Msg
config =
    DropUp.customConfig
        { displayText = "Example"
        , stateToMsg = SetDropDownState
        , dataToMsg = SetItems
        , dataToString = (\item -> item)
        , displayDirection = DropUp.Up
        , displayCheckAllButtons = True
        }
