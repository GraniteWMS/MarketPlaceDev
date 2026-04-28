Select Existing session or enter new name to start new session

{{ "select Name from StockTakeSession WHERE Active = 1" | dbSelect({}) | basicList({submitOnClick:true}) }}