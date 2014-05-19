require './setup_teardown'
should = require 'should'
{wd40, browser, base_url, loginAndGo} = require './helper'
cleaner = require '../cleaner'

describe 'New view tool', ->

  before (done) ->
    # TODO(pwaller): Not sure why this is needed, but it interacts with the API
    #                tests otherwise
    # NOTE: It hangs trying to click "Apricot", possibly because it's in the non
    # tial view. But I'm unsure.
    cleaner.clear_and_set_fixtures done

  before (done) ->
    loginAndGo 'ehg', 'testing', "/datasets", done

  context 'when I click on an Apricot dataset', ->
    before (done) ->
        wd40.elementByPartialLinkText 'Apricot', (err, link) ->
          link.click done

    it 'takes me to the Apricot dataset page', (done) ->
      wd40.trueURL (err, result) ->
        result.should.match /\/dataset\/(\w+)/
        done()

    context 'when I click on "More tools" in the toolbar', ->
      before (done) ->
        setTimeout done, 500 # wait for window to get big enough!

      before (done) ->
        wd40.click '#toolbar .new-view', ->
          browser.waitForElementByCss '#chooser .tool', 4000, done

      context 'when I click on the newview tool', ->
        before (done) ->
          wd40.click '.newview.tool', =>
            wd40.waitForInvisibleByCss '#chooser', (err) =>
              browser.url (err, url) =>
                @currentUrl = url
                done()
            , 4000

        before (done) ->
          setTimeout done, 2000

        it 'takes me to the view page', (done) ->
          wd40.waitForMatchingURL new RegExp("#{base_url}/dataset/[^/]+/view/[^/]+"), done

    context 'when I click on "More tools" in the toolbar (again)', ->
      before (done) ->
        wd40.click '#toolbar .new-view', ->
          browser.waitForElementByCss '#chooser .tool', 4000, done

      context 'when I click on the newview tool', ->
        before (done) ->
          wd40.click '.newview.tool', (err) =>
            wd40.waitForInvisibleByCss '#chooser', (err) =>
              browser.url (err, url) =>
                @currentUrl = url
                done()
            , 4000

        it 'takes me to the view page', (done) ->
          wd40.waitForMatchingURL new RegExp("#{base_url}/dataset/[^/]+/view/[^/]+"), done

        it 'does not show two new view tools', (done) ->
          browser.elementsByCssSelector '[data-toolname=newview]', (err, tools) ->
            tools.length.should.equal 1
            done()
