import os.log
import Foundation

// conver i18n JSON templates to strings files
private func convert(from inputDirectoryURL: URL, to outputDirectory: URL) {
    do {
        let inputLanguageDirectoryURLs = try FileManager.default.contentsOfDirectory(
            at: inputDirectoryURL,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: []
        )
        for inputLanguageDirectoryURL in inputLanguageDirectoryURLs {
            let language = inputLanguageDirectoryURL.lastPathComponent
            guard let mappedLanguage = map(language: language) else { continue }
            os_log("%{public}s[%{public}ld], %{public}s: process %s -> %s", ((#file as NSString).lastPathComponent), #line, #function, language, mappedLanguage)
            
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: inputLanguageDirectoryURL,
                includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
                options: []
            )
            for jsonURL in fileURLs where jsonURL.pathExtension == "json" {
                os_log("%{public}s[%{public}ld], %{public}s: process %s", ((#file as NSString).lastPathComponent), #line, #function, jsonURL.debugDescription)
                let filename = jsonURL.deletingPathExtension().lastPathComponent
                guard let (mappedFilename, keyStyle) = map(filename: filename) else { continue }
                guard let bundle = bundle(filename: filename) else { continue }
                
                let outputDirectoryURL = outputDirectory
                    .appendingPathComponent(bundle, isDirectory: true)
                    .appendingPathComponent(mappedLanguage + ".lproj", isDirectory: true)

                let outputFileURL = outputDirectoryURL
                    .appendingPathComponent(mappedFilename)
                    .appendingPathExtension("strings")
                
                let strings = try process(url: jsonURL, keyStyle: keyStyle)
                try? FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                
                try strings.write(to: outputFileURL, atomically: true, encoding: .utf8)
            }
        }
    } catch {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
        exit(1)
    }
}

private func map(language: String) -> String? {
    switch language {
    case "ar_SA":   return "ar"         // Arabic (Saudi Arabia)
    case "eu_ES":   return "eu-ES"      // Basque
    case "ca_ES":   return "ca"         // Catalan
    case "zh_CN":   return "zh-Hans"    // Chinese Simplified
    case "nl_NL":   return "nl"         // Dutch
    case "en_US":   return "en"
    case "fr_FR":   return "fr"         // French
    case "de_DE":   return "de"         // German
    case "ja_JP":   return "ja"         // Japanese
    case "kab_KAB": return "kab"        // Kabyle
    case "kmr_TR":  return "ku"         // Kurmanji (Kurdish)
    case "ru_RU":   return "ru"         // Russian
    case "gd_GB":   return "gd-GB"      // Scottish Gaelic
    case "es_ES":   return "es"         // Spanish
    case "es_AR":   return "es-419"     // Spanish, Argentina
    case "sv_FI":   return "sv_FI"      // Swedish, Finland
    case "th_TH":   return "th"         // Thai
    case "vi_VN":   return "vi"         // Vietnamese
    default:        return nil
    }
}

private func map(filename: String) -> (filename: String, keyStyle: Parser.KeyStyle)? {
    switch filename {
    case "app":             return ("Localizable", .swiftgen)
    case "ios-infoPlist":   return ("infoPlist", .infoPlist)
    default:                return nil
    }
}

private func bundle(filename: String) -> String? {
    switch filename {
    case "app":             return "module"
    case "ios-infoPlist":   return "main"
    default:                return nil
    }
}

private func process(url: URL, keyStyle: Parser.KeyStyle) throws -> String {
    do {
        let data = try Data(contentsOf: url)
        let parser = try Parser(data: data)
        let strings = parser.generateStrings(keyStyle: keyStyle)
        return strings
    } catch {
        os_log("%{public}s[%{public}ld], %{public}s: error: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
        throw error
    }
}

// keep path extension and only rename the folder name
private func move(from inputDirectoryURL: URL, to outputDirectoryURL: URL, pathExtension: String) {
    do {
        let inputLanguageDirectoryURLs = try FileManager.default.contentsOfDirectory(
            at: inputDirectoryURL,
            includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
            options: []
        )
        for inputLanguageDirectoryURL in inputLanguageDirectoryURLs {
            let language = inputLanguageDirectoryURL.lastPathComponent
            guard let mappedLanguage = map(language: language) else { continue }
            let outputDirectoryURL = outputDirectoryURL.appendingPathComponent(mappedLanguage + ".lproj", isDirectory: true)
            os_log("%{public}s[%{public}ld], %{public}s: process %s -> %s", ((#file as NSString).lastPathComponent), #line, #function, language, mappedLanguage)
            
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: inputLanguageDirectoryURL,
                includingPropertiesForKeys: [.nameKey, .isDirectoryKey],
                options: []
            )
            for dictURL in fileURLs where dictURL.pathExtension == pathExtension {
                os_log("%{public}s[%{public}ld], %{public}s: process %s", ((#file as NSString).lastPathComponent), #line, #function, dictURL.debugDescription)
                let filename = dictURL.deletingPathExtension().lastPathComponent
                
                let outputFileURL = outputDirectoryURL.appendingPathComponent(filename).appendingPathExtension(pathExtension)
                try? FileManager.default.createDirectory(at: outputDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.copyItem(at: dictURL, to: outputFileURL)
            }
        }
    } catch {
        os_log("%{public}s[%{public}ld], %{public}s: %s", ((#file as NSString).lastPathComponent), #line, #function, error.localizedDescription)
        exit(2)
    }
}


let currentFileURL = URL(fileURLWithPath: "\(#file)", isDirectory: false)
let packageRootURL = currentFileURL.deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()

let inputDirectoryURL = packageRootURL.appendingPathComponent("input", isDirectory: true)
let outputDirectoryURL = packageRootURL.appendingPathComponent("output", isDirectory: true)
convert(from: inputDirectoryURL, to: outputDirectoryURL)

let moduleDirectoryURL = outputDirectoryURL.appendingPathComponent("module", isDirectory: true)
move(from: inputDirectoryURL, to: moduleDirectoryURL, pathExtension: "stringsdict")

// i18n from "Intents/input" to "Intents/output"
let intentsDirectoryURL = packageRootURL.appendingPathComponent("Intents", isDirectory: true)
let inputIntentsDirectoryURL = intentsDirectoryURL.appendingPathComponent("input", isDirectory: true)
let outputIntentsDirectoryURL = intentsDirectoryURL.appendingPathComponent("output", isDirectory: true)
move(from: inputIntentsDirectoryURL, to: outputIntentsDirectoryURL, pathExtension: "strings")
