//
//  SearchTextField.swift
//  testPullDown
//
//  Created by osu on 2018/02/05.
//  Copyright © 2018 osu. All rights reserved.
//

import UIKit

class SearchTextField: UITextField {

    fileprivate var tableView: UITableView?
    fileprivate static let cellIdentifier = "f3QmuB2G"
    fileprivate static let cellHeight: CGFloat = 44.0
    fileprivate static let cellMaxRow: CGFloat = 5
    fileprivate var cellHighlightAttributes: [NSAttributedStringKey: AnyObject]!
    fileprivate var cellHighlightAttributesSubtitle: [NSAttributedStringKey: AnyObject]!

    fileprivate var filteredResults = [SearchTextFieldItem]()
    var filterDataSource = [SearchTextFieldItem]()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initTableView()
        cellHighlightAttributes = [.font: UIFont.boldSystemFont(ofSize: font!.pointSize)]
        cellHighlightAttributesSubtitle = [.font: UIFont.boldSystemFont(ofSize: (font!.pointSize * 0.7))]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTableView()
        cellHighlightAttributes = [.font: UIFont.boldSystemFont(ofSize: font!.pointSize)]
        cellHighlightAttributesSubtitle = [.font: UIFont.boldSystemFont(ofSize: (font!.pointSize * 0.7))]
    }

    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        self.addTarget(self, action: #selector(SearchTextField.textFieldDidChange), for: .editingChanged)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidBeginEditing), for: .editingDidBegin)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditing), for: .editingDidEnd)
        self.addTarget(self, action: #selector(SearchTextField.textFieldDidEndEditingOnExit), for: .editingDidEndOnExit)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        guard let tableView = self.tableView else {
            return
        }
 
        if tableView.isDescendant(of: self.window!) == false {
            window!.addSubview(tableView)
        }

        drawTableView()
    }

    fileprivate func initTableView() {
        tableView = UITableView(frame: CGRect.zero)
        guard let tableView = tableView else {
            return
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        tableView.layer.masksToBounds = true
        tableView.layer.borderWidth = 0.5
        tableView.layer.borderColor = #colorLiteral(red: 0.8666666667, green: 0.8666666667, blue: 0.8666666667, alpha: 1)
    }

    fileprivate func drawTableView() {
        guard let tableView = self.tableView else {
            return
        }

        tableView.reloadData()

        let tableViewHeight = min((CGFloat(filteredResults.count) * SearchTextField.cellHeight), (UIScreen.main.bounds.size.height - frame.origin.y - frame.height), SearchTextField.cellHeight * SearchTextField.cellMaxRow)
        let textFieldPoint = convert(bounds.origin, to: nil)
        let tableViewFrame = CGRect(x: textFieldPoint.x + 2, y: textFieldPoint.y + frame.size.height, width: frame.size.width - 4, height: tableViewHeight)

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.tableView?.frame = tableViewFrame
        })

        window?.bringSubview(toFront: tableView)
        if isFirstResponder {
            superview?.bringSubview(toFront: self)
        }
        
        tableView.separatorColor = UIColor.clear
    }

    fileprivate func updateResults() {
        guard let tableView = self.tableView else {
            return
        }

        filteredResults.removeAll()
        filter()
        tableView.isHidden = (filteredResults.count == 0)
    }

    fileprivate func clearResults() {
        guard let tableView = self.tableView else {
            return
        }
        
        filteredResults.removeAll()
        tableView.removeFromSuperview()
    }

    fileprivate func filter() {
        guard let text = self.text, text.isEmpty == false else {
            return
        }

        for item in filterDataSource {
            // Find text in title and subtitle
            let titleFilterRange = (item.title as NSString).range(of: text, options: [.caseInsensitive])
            let subtitleFilterRange = item.subtitle != nil ? (item.subtitle! as NSString).range(of: text, options:
                [.caseInsensitive]) : NSMakeRange(NSNotFound, 0)
            
            guard titleFilterRange.location != NSNotFound || subtitleFilterRange.location != NSNotFound else {
                continue
            }

            item.titleAttributed = NSMutableAttributedString(string: item.title)
            item.subtitleAttributed = NSMutableAttributedString(string: (item.subtitle != nil ? item.subtitle! : ""))
            
            item.titleAttributed!.setAttributes(cellHighlightAttributes, range: titleFilterRange)
            if subtitleFilterRange.location != NSNotFound {
                item.subtitleAttributed!.setAttributes(cellHighlightAttributesSubtitle, range: subtitleFilterRange)
            }
            
            filteredResults.append(item)
        }
    }

    @objc open func textFieldDidChange() {
        updateResults()
    }
    
    @objc open func textFieldDidBeginEditing() {
        guard text?.isEmpty == false else {
            return
        }

        updateResults()
    }
    
    @objc open func textFieldDidEndEditing() {
        clearResults()
    }

    @objc open func textFieldDidEndEditingOnExit() {
        if let firstElement = filteredResults.first {
            self.text = firstElement.title
        }
    }

}

extension SearchTextField: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResults.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: SearchTextField.cellIdentifier)
        if cell == nil {
            cell = createCell()
        }

        cell!.textLabel?.text = filteredResults[(indexPath as NSIndexPath).row].title
        cell!.detailTextLabel?.text = filteredResults[(indexPath as NSIndexPath).row].subtitle
        cell!.textLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].titleAttributed
        cell!.detailTextLabel?.attributedText = filteredResults[(indexPath as NSIndexPath).row].subtitleAttributed

        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SearchTextField.cellHeight
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        text = filteredResults[(indexPath as NSIndexPath).row].title
        clearResults()
    }

    private func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: SearchTextField.cellIdentifier)
        cell.backgroundColor = UIColor.clear
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.textLabel?.font = font
        cell.detailTextLabel?.font = UIFont(name: font!.fontName, size: (font!.pointSize * 0.7))
        cell.textLabel?.textColor = textColor
        cell.detailTextLabel?.textColor = textColor
        cell.selectionStyle = .none
        return cell
    }

}

class SearchTextFieldItem {

    fileprivate var titleAttributed: NSMutableAttributedString?
    fileprivate var subtitleAttributed: NSMutableAttributedString?

    public var title: String
    public var subtitle: String?

    public init(_ title: String, _ subtitle: String?) {
        self.title = title
        self.subtitle = subtitle
    }

    public init(_ title: String) {
        self.title = title
    }

}
