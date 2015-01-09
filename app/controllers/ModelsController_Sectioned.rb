class ModelsController
  class SectionedModelsDataSource
    attr_accessor :controller, :models, :category
  
    def initialize(controller, models = Model.all)
      @controller = controller
      @initialModels = models
      @isAllModelsView = models == Model.all
      @initialModelsIndex = @isAllModelsView ? Model::IndexByBrand.new : @initialModels.indexBy { |m| m.brand.key }
      @initialBrands = @isAllModelsView ? Brand.all : @initialModelsIndex.keys.sort.map { |k| Brand[k] }
      @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
    end
  
    def numberOfSectionsInTableView(tv)
      @brands.count
    end

    def tableView(tv, titleForHeaderInSection:section)
      @brands[section].name
    end

    def tableView(tv, numberOfRowsInSection:section)
      @modelsIndex[@brands[section].key].count
    end

    def tableView(table, cellForRowAtIndexPath:indexPath)  
      @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      modelSelectedModsCount = model.selectedModsCount

      cell = table.dequeueReusableCell(style: UITableViewCellStyleValue1) { |cell| cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator }
      cell.textLabel.text = model.unbrandedName
      cell.detailTextLabel.text = modelSelectedModsCount.to_s_or_nil
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      controller.tableView.deselectRowAtIndexPath indexPath, animated:YES
      controller.navigationController.pushViewController ModsController.new(model), animated:YES
    end

    def sectionIndexTitlesForTableView(tv)
      [UITableViewIndexSearch] + @brands.map { |brand| brand.name.chr }.uniq    
    end

    def tableView(tableView, sectionForSectionIndexTitle:letter, atIndex:index)
      if letter == UITableViewIndexSearch || letter == 'A'
        tableView.scrollRectToVisible(controller.searchBar.frame, animated:NO)
        return -1
      end
      @brands.index { |brand| brand.name.chr == letter }
    end  



    def searchDisplayController(ctl, willShowSearchResultsTableView:tbl)
      controller.navigationItem.backBarButtonItem = KK.textBBI("Search")  
    end  

    def searchDisplayController(ctl, shouldReloadTableForSearchString:newSearchString)
      @currentModels = @models
      loadDataForSearchString(newSearchString)
      @currentModels != @models
    end
  
    def searchBarCancelButtonClicked(searchBar)
      loadDataForSearchString("")
      controller.tableView.reloadVisibleRows
      controller.navigationItem.backBarButtonItem = KK.textBBI(controller.currentShortTitle)
    end



    def loadDataForSearchString(newSearchString)
      if newSearchString.empty?
        @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
      else
        collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @models : @initialModels
        @models = Model.modelsForText(newSearchString, inCollection:collectionToSearch)
        @modelsIndex = @models.indexBy { |ml| ml.brand.key }
        @brands = @modelsIndex.keys.sort.map { |k| Brand[k] }
      end
      @currentSearchString = newSearchString
    end    
  end
end