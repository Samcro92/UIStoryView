//
//  StoriesViewController.swift
//  UIStoryView
//
//  Created by Volkan Sonmez on 24.12.2019.
//  Copyright © 2019 Porte. All rights reserved.
//

import UIKit

open class StoriesViewController: UIViewController
{

    @IBOutlet weak var storyScrollView: StoryScrollView!
    
    fileprivate var storiesSectionModel: [IStorySection]?;
    
    private var storiesSectionView = [StorySectionView]();
    
    fileprivate var tintColor: UIColor?;
    fileprivate var progressColor: UIColor?;
    
    private var currentIndex = 0;
    
    fileprivate class func createInstance() -> StoriesViewController
    {
        let podBundle = Bundle(for: StoriesViewController.self)
        let bundleURL = podBundle.url(forResource: "UIStoryView", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        return UIStoryboard(name: "Story", bundle: bundle).instantiateViewController(withIdentifier: "StoriesViewController") as! StoriesViewController;
    }
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        self.setUp();
        self.commonInit();
    }
    
    private func commonInit()
    {
        self.storyScrollView.onDidChange = { [weak self] (rowIndex) in
            self?.onDidChange(rowIndex: rowIndex)
        }
    }
    
    private func pauseAllVideo() {
        for sectionView in storiesSectionView {
            sectionView.canVideoPlay = false
            sectionView.removeStoryViews()
        }
    }
    
    private func resetNearStory(rowIndex: Int)
    {
        if (rowIndex > 0)
        {
            resetStory(rowIndex: rowIndex - 1);
        }
        if (rowIndex < self.storiesSectionView.count - 1)
        {
            self.resetStory(rowIndex: rowIndex + 1);
        }
    }
    
    private func resetStory(rowIndex: Int)
    {
        self.storiesSectionView[rowIndex].resetSection();
        self.storiesSectionView[rowIndex].isPause = true;
    }
    
    private func removeAllStories() {
        for sectionView in storiesSectionView {
            sectionView.removeStoryViews()
        }
    }
    
    private func setUp()
    {
        for index in 0...self.storiesSectionModel!.count - 1
        {
            let section = self.storiesSectionModel![index];
            let sectionView = StorySectionView(frame: self.view.bounds, storiesModel: section.getStories(), storyTintColor: self.tintColor!, storyProgressColor: self.progressColor!, canVideoPlay: index == 0);
            sectionView.isPause = (index > 0);
            self.storiesSectionView.append(sectionView);
            sectionView.onClose = { [weak self] in
                self?.close()
            }
            sectionView.onNext = { [weak self] in
                guard let self = self else { return }
                if (self.currentIndex < self.storiesSectionModel!.count - 1)
                {
                    self.scrollToSection(index: self.currentIndex + 1)
                }
                else
                {
                    self.dismiss(animated: true, completion: nil);
                }
            }
            sectionView.onPrevious = { [weak self] in
                guard let self = self else { return }
                if self.currentIndex > 0 {
                    self.scrollToSection(index: self.currentIndex - 1)
                } else {
                    self.close()
                }
            }
        }
        self.storyScrollView.addChildViews(self.storiesSectionView);
    }
    
    private func scrollToSection(index: Int) {
        self.currentIndex = index
        self.storiesSectionView[self.currentIndex].resetSection();
        self.storiesSectionView[self.currentIndex].isPause = false;
        self.storyScrollView.scrollToViewAtIndex(self.currentIndex, animated: true);
    }
    
    private func onDidChange(rowIndex: Int) {
        self.storiesSectionView[rowIndex].isPause = false;
        if self.currentIndex != rowIndex {
            self.pauseAllVideo()
            self.storiesSectionView[rowIndex].canVideoPlay = true
            self.resetNearStory(rowIndex: rowIndex);
            self.currentIndex = rowIndex;
            self.storiesSectionView[rowIndex].resetSection();
        } else {
            self.storiesSectionView[rowIndex].play()
        }
    }
    
    private func close() {
        removeAllStories()
        dismiss(animated: true, completion: nil);
    }
    
    override open var prefersStatusBarHidden: Bool
    {
        return true;
    }
}

open class StoriesBuilder
{
    private var storiesVC: StoriesViewController!;
    private var trackTintColor: UIColor = UIColor(red: 216, green: 216, blue: 216).withAlphaComponent(0.48);
    private var progressTintColor: UIColor = UIColor(red: 57, green: 151, blue: 254);
    private var stories: [IStorySection]!;
    
    public init(stories: [IStorySection])
    {
        self.storiesVC = StoriesViewController.createInstance();
        self.stories = stories;
    }
    
    public func setTrackTintColor(color: UIColor) -> StoriesBuilder
    {
        self.trackTintColor = color;
        return self;
    }
    
    public func setProgressTintColor(color: UIColor) -> StoriesBuilder
    {
        self.progressTintColor = color;
        return self;
    }
    
    public func build() -> StoriesViewController
    {
        self.storiesVC.storiesSectionModel = self.stories;
        self.storiesVC.tintColor = self.trackTintColor;
        self.storiesVC.progressColor = self.progressTintColor;
        return storiesVC;
    }
    
}
