//
//  OpenSourceLicense.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import Foundation
import SwiftUI
import os

struct License: Codable, Identifiable {
    let licenseName: String
    let licenseText: String
    let packageName: String
    
    var id: String { packageName }
}

extension License {
    static let mock: License = .init(licenseName: "MIT", licenseText: "MIT license text", packageName: "Test Dependency")
}

final class LicensesViewModel: ObservableObject {
    @Published private(set) var licenses: [License] = []
    #warning("update subsystem string")
    private let logger = Logger(subsystem: "us.goding.lanvoyage", category: String(describing: LicensesViewModel.self))

    init() {
        #warning("make sure licenses.json is added to the project")
        guard let url = Bundle.main.url(forResource: "licenses", withExtension: "json") else {
            logger.debug("Could not read licenses because file does not exist.")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            self.licenses = try JSONDecoder().decode([License].self, from: data)
        } catch {
            logger.debug("Could not read licenses: \(error.localizedDescription, privacy: .public)")
        }
    }
}

struct LicensesView: View {
    @ObservedObject var viewModel: LicensesViewModel

    var body: some View {
        List(viewModel.licenses) { license in
            LicenseView(license: license)
        }.navigationBarTitle(Text("Licenses"), displayMode: .inline)
    }
}

struct LicensesView_Previews: PreviewProvider {
    static var previews: some View {
        LicensesView(viewModel: .init())
    }
}

struct LicenseView: View {
    let license: License
    var body: some View {
        NavigationLink(destination: LicenseDetailView(license: license)) {
            HStack {
                Text(license.packageName)
                    .font(.body)
                Spacer()
                Text(license.licenseName)
                    .font(.body)
                    .foregroundColor(Color(.secondaryLabel))
            }
        }
    }
}

struct LicenseView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseView(license: .mock)
    }
}

struct LicenseDetailView: View {
    let license: License
    
    var body: some View {
        ScrollView {
            VStack {
                Text(license.licenseText)
                Spacer()
            }.padding()
        }.navigationBarTitle(Text(license.packageName), displayMode: .inline)
    }
}

struct LicenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LicenseDetailView(license: .mock)
    }
}
