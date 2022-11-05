//
//  NewStreamView.swift
//  LiveEvents
//
//  Created by Serhii Krotkykh on 10/14/22.
//

import SwiftUI

struct NewStreamView: View {
    @EnvironmentObject var viewModel: NewNewStreamViewModel

    var body: some View {
        if !viewModel.error.isEmpty {
            VStack {
                Spacer()
                    .frame(height: 40.0)
                Text(viewModel.error)
                    .foregroundColor(.red)
            }
        }
        NewStreamContentView(model: $viewModel.model)
        .padding(.top, 30.0)
        .navigationBarTitle(Text("Schedule a new live video"), displayMode: .inline)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton(),
                            trailing: DoneButton())
        .onAppear {
        }
    }

    struct NewStreamContentView: View {
        @Binding var model: NewStream

        var body: some View {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $model.title)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("Description")) {
                    TextField("Description", text: $model.description)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("After Hours")) {
                    TextField("Hours", text: $model.hours)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("After Minutes")) {
                    TextField("Minutes", text: $model.minutes)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                Section(header: Text("After Seconds")) {
                    TextField("Seconds", text: $model.seconds)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                }
                DatePicker("Date", selection: $model.date, displayedComponents: .date)
            }
        }
    }

    struct DoneButton: View {
        @EnvironmentObject var viewModel: NewNewStreamViewModel

        var body: some View {
            HStack {
                Button(action: {
                    viewModel.done()
                }, label: {
                    HStack {
                        Text("Done")
                            .foregroundColor(.white)
                    }
                })
            }
        }
    }
}
