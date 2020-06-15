defmodule Organizer.ReadyMadeLists do

    alias Organizer.Lists

    @readymadelists %{
        default: ["Create checklist", "Delegate it by sharing it", "Add your email", "Get notified once it's done"],
        panther: ["to do", "to do", "to do, to do, to do", "todo dodooooooo"]
    }

    def get_template_tasks(template \\ "default") do
        # take list_template from readymadelists
        tasks = @readymadelists[template |> String.to_atom] # returns list of strings
    end

end