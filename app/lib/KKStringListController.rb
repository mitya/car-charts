# Just displays a table view of strings.
# It can be used to determine if those strings fit the screen.
# window.rootViewController = KKStringListController.new(Scripts.modNames)
class KKStringListController < UITableViewController
  def initialize(strings)
    @strings = strings
  end

  def viewDidLoad
    tableView.rowHeight = 30
  end

  def tableView(tv, numberOfRowsInSection:section)
    @strings.count
  end

  def tableView(tv, cellForRowAtIndexPath:indexPath)
    string = @strings[indexPath.row]

    cell = tv.dequeueReusableCell(style:UITableViewCellStyleDefault) do |cell|
      cell.textLabel.font = KK.mainFont(12)
    end
    cell.textLabel.text = "#{string.length} #{string}"
    cell
  end
end
