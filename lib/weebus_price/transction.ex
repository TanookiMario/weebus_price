defmodule WeebusPrice.Transaction do
  defstruct date: nil,
            description: nil,
            original_description: nil,
            amount: nil,
            type: nil,
            category: nil,
            account: nil,
            labels: nil,
            notes: nil
end
