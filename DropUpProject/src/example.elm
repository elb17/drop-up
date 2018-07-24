import Html
import Html.Attributes as App
import Html.Events
import String
import DropUp


type alias Model =
    { data : List String
    , dropdownState : DropUp.State
    }

init : (Model, Cmd Msg)
init =
    ({data = ["a", "b", "c"], dropdownState = DropUp.initialState([])}, Cmd.none)


-- Update

type Msg
    = SetDropDownState DropUp.State

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        SetDropDownState newState ->
            ( { model | dropdownState = newState }
            , Cmd.none
            )

-- VIEW

view : Model -> Html.Html Msg
view { data, dropdownState } =
    Html.div []
    [ Html.text "hi" ]
--    , DropUp.view
--    config
--    dropdownState
--    data
--    ]

config : DropUp.Config Msg
config =
    DropUp.config
    { displayText = "Hi",
    toMsg = SetDropDownState }