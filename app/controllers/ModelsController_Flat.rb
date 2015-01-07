class ModelsController
  class FlatModelsDataSource
    attr_accessor :controller, :models, :category
  
    def initialize(controller, models, category = nil)
      @controller = controller
      @category = category
      @initialModels = models      
      @filteredModels = @initialModels
    end

    def models=(objects)
      @initialModels = objects
      @filteredModels = @initialModels
    end
  
    def tableView(tv, numberOfRowsInSection:section)
      @filteredModels.count
    end

    def tableView(tableView, cellForRowAtIndexPath:indexPath)  
      model = @filteredModels[indexPath.row]
      modelSelectedModsCount = model.selectedModsCount

      cell = tableView.dequeueReusableCell(style: UITableViewCellStyleValue1) { |cl| cl.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
      cell.textLabel.text = model.name
      cell.detailTextLabel.text = modelSelectedModsCount.to_s_or_nil
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      model = @filteredModels[indexPath.row]
      tableView.deselectRowAtIndexPath indexPath, animated:YES
      controller.navigationController.pushViewController ModsController.new(model), animated:YES
    end



    def searchDisplayController(ctl, willHideSearchResultsTableView:tbl)
      loadDataForSearchString("")
      controller.tableView.reloadVisibleRows
      controller.navigationItem.backBarButtonItemTitle = controller.currentShortTitle
    end

    def searchDisplayController(ctl, willShowSearchResultsTableView:tbl)
      controller.navigationItem.backBarButtonItem = KK.textBBI("Search")
    end  

    def searchDisplayController(controller, shouldReloadTableForSearchString:newSearchString)
      @currentModels = @filteredModels
      loadDataForSearchString(newSearchString)
      @currentModels != @filteredModels
    end


    def loadDataForSearchString(newSearchString)
      collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @filteredModels : @initialModels
      @filteredModels = newSearchString.empty? ? @initialModels : Model.modelsForText(newSearchString, inCollection:collectionToSearch)
      @currentSearchString = newSearchString
    end    
  end
end