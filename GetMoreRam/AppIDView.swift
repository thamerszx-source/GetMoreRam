//
//  AppIDView.swift
//  GetMoreRam
//
//  Created by s s on 2025/3/15.
//
import SwiftUI

struct AppIDEditView : View {
    @StateObject var viewModel : AppIDModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    @State private var isSubmitting = false
    
    var body: some View {
        Form {
            Section {
                ForEach(AppIDCapability.allCases) { capability in
                    Button {
                        Task { await addCapabilities([capability]) }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(capability.title)
                            Text(capability.entitlement)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(isSubmitting)
                }
                
                Button {
                    Task { await addCapabilities(AppIDCapability.allCases) }
                } label: {
                    Text("Add Both")
                }
                .disabled(isSubmitting)
            } footer: {
                Text("Each button only enables the capability it names. Tap \"Add Both\" to enable them together in a single request.")
            }
            
            Section {
                Text(viewModel.result)
                    .font(.system(.subheadline, design: .monospaced))
            } header: {
                Text("Server Response")
            }
        }
        .alert("Error", isPresented: $errorShow){
            Button("OK".loc, action: {
            })
        } message: {
            Text(errorInfo)
        }
        .navigationTitle(viewModel.bundleID)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @MainActor
    func addCapabilities(_ capabilities: [AppIDCapability]) async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        do {
            try await viewModel.addCapabilities(capabilities)
        } catch {
            errorInfo = error.detailedDescription
            errorShow = true
        }

    }
}


struct AppIDView : View {
    @StateObject var viewModel : AppIDViewModel
    
    @State private var errorShow = false
    @State private var errorInfo = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(viewModel.appIDs, id: \.self) { appID in
                        NavigationLink {
                            AppIDEditView(viewModel: appID)
                        } label: {
                            Text(appID.bundleID)
                        }
                    }
                } header: {
                    Text("App IDs")
                }
                
                Section {
                    Button("Refresh") {
                        Task { await refreshButtonClicked() }
                    }
                }
            }
            .alert("Error", isPresented: $errorShow){
                Button("OK".loc, action: {
                })
            } message: {
                Text(errorInfo)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func refreshButtonClicked() async {
        do {
            try await viewModel.fetchAppIDs()
        } catch {
            errorInfo = error.detailedDescription
            errorShow = true
        }
    }
}
