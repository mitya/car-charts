class ModelListController < UIViewController
  class SectionedModelsDataSource
    attr_accessor :controller, :models, :category
  
    def initialize(controller, models = ModelGeneration.all)
      @controller = controller
      @initialModels = models
      @isAllModelsView = models == ModelGeneration.all
      @initialModelsIndex = @isAllModelsView ? ModelGeneration::IndexByBrand.new : @initialModels.indexBy { |m| m.brand.key }
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

      cell = table.dequeueReusableCell(style: UITableViewCellStyleValue1) do |c|
        c.accessoryType = UITableViewCellAccessoryDisclosureIndicator
      end

      text = NSMutableAttributedString.alloc.init

      model_name = NSAttributedString.alloc.initWithString model.family.unbrandedName + ' ', attributes: { }
      year = NSAttributedString.alloc.initWithString model.year_apostrophe, attributes: {
        NSFontAttributeName => UIFont.systemFontOfSize(14),
        NSForegroundColorAttributeName => UIColor.lightGrayColor }

      text.appendAttributedString(model_name)
      text.appendAttributedString(year)
    
      cell.textLabel.attributedText = text
      cell.detailTextLabel.text = modelSelectedModsCount.to_s_or_nil
      cell
    end

    def tableView(tableView, didSelectRowAtIndexPath:indexPath)
      model = @modelsIndex[@brands[indexPath.section].key][indexPath.row]
      controller.tableView.deselectRowAtIndexPath indexPath, animated:YES
      controller.navigationController.pushViewController ModListController.new(model), animated:YES
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
      currentModels = @models
      loadDataForSearchString(newSearchString)
      return currentModels != @models
    end
  
    def searchBarCancelButtonClicked(searchBar)
      loadDataForSearchString("")
      controller.tableView.reloadData
      controller.navigationItem.backBarButtonItem = KK.textBBI(controller.currentShortTitle)
    end



    def loadDataForSearchString(newSearchString)
      if newSearchString.empty?
        @models, @modelsIndex, @brands = @initialModels, @initialModelsIndex, @initialBrands
      else
        collectionToSearch = newSearchString.start_with?(@currentSearchString) ? @models : @initialModels
        @models = ModelGeneration.modelsForText(newSearchString, inCollection:collectionToSearch)
        @modelsIndex = @models.indexBy { |ml| ml.brand.key }
        @brands = @modelsIndex.keys.sort.map { |k| Brand[k] }
      end
      @currentSearchString = newSearchString
    end    
  end
end
